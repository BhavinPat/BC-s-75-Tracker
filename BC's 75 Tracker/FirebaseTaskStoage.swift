//
//  FirebaseTaskStoage.swift
//  BC's 75 Tracker
//
//  Created by Bhavin Patel on 1/26/25.
//

import SwiftUI
import PhotosUI
import FirebaseStorage

// View Model to handle image selection and upload
@Observable
class PhotoUploadViewModel {
    // Published properties to manage UI state
    var selectedItem: PhotosPickerItem? = nil
    var selectedImageData: Data? = nil
    var isConfirmationShown = false
    var uploadProgress: Double = 0.0
    var uploadComplete = false
    var uploadError: Error? = nil
    var taskPath: String = ""
    
    // Convert selected image to PNG data
    func convertToPNGData() -> Data? {
        guard let selectedImageData = selectedImageData,
              let uiImage = UIImage(data: selectedImageData) else {
            return nil
        }
        return uiImage.pngData()
    }
    /// Retrieves an image from Firebase Storage and returns a SwiftUI Image
    /// - Parameters:
    ///   - taskPath: The path in Firebase Storage where the image is stored
    ///   - filename: The name of the image file
    /// - Returns: A SwiftUI Image
    /// - Throws: `ImageRetrievalError` if the image cannot be retrieved or converted
    func getPhoto(filename: String = "progressPic.png") async throws -> Image {
        // Create reference to the specific image in Firebase Storage
        let storageRef = Storage.storage().reference().child("\(taskPath)/\(filename)")
        
        do {
            // Attempt to download image data
            let imageData = try await storageRef.downloadData()
            
            // Convert downloaded data to UIImage
            guard let uiImage = UIImage(data: imageData) else {
                throw ImageRetrievalError.conversionFailed
            }
            
            // Convert UIImage to SwiftUI Image
            return Image(uiImage: uiImage)
        } catch {
            // Handle specific error scenarios
            switch error {
                case ImageRetrievalError.imageNotFound:
                    print("No image found at the specified path")
                case ImageRetrievalError.downloadFailed(let originalError):
                    print("Download failed: \(originalError.localizedDescription)")
                case ImageRetrievalError.conversionFailed:
                    print("Failed to convert image data")
                default:
                    print("Unexpected error: \(error.localizedDescription)")
            }
            
            // Re-throw the error for the caller to handle
            throw error
        }
    }
    // Upload image to Firebase Storage
    func uploadImageToFirebase() {
        // Ensure we have PNG data
        guard let pngData = convertToPNGData() else {
            uploadError = NSError(domain: "PhotoUpload",
                                  code: 0,
                                  userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
            return
        }
        
        // Create a unique filename
        let filename = "progressPic.png"
        
        // Reference to Firebase Storage
        let storageRef = Storage.storage().reference().child("\(taskPath)/\(filename)")
        
        // Upload task with progress tracking
        let uploadTask = storageRef.putData(pngData, metadata: nil) { [weak self] metadata, error in
            guard let self = self else { return }
            
            if let error = error {
                // Handle upload error
                DispatchQueue.main.async {
                    self.uploadError = error
                    self.uploadComplete = false
                }
                return
            }
            
            // Upload successful
            DispatchQueue.main.async {
                self.uploadComplete = true
                self.uploadProgress = 1.0
            }
        }
        
        // Track upload progress
        uploadTask.observe(.progress) { [weak self] snapshot in
            guard let self = self else { return }
            let progress = Double(snapshot.progress?.completedUnitCount ?? 0) /
            Double(snapshot.progress?.totalUnitCount ?? 1)
            DispatchQueue.main.async {
                self.uploadProgress = progress
            }
        }
    }
}

enum ImageRetrievalError: Error {
    case imageNotFound
    case downloadFailed(Error)
    case conversionFailed
}

extension StorageReference {
    // Async method to download image data
    func downloadData(maxSize: Int64 = 1024 * 1024 * 1024) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            self.getData(maxSize: maxSize) { data, error in
                if let error = error {
                    continuation.resume(throwing: ImageRetrievalError.downloadFailed(error))
                    return
                }
                
                guard let data = data else {
                    continuation.resume(throwing: ImageRetrievalError.imageNotFound)
                    return
                }
                
                continuation.resume(returning: data)
            }
        }
    }
}
