//
//  FirebaseTaskStoage.swift
//  BC's 75 Tracker
//
//  Created by Bhavin Patel on 1/26/25.
//

import SwiftUI
import PhotosUI
import FirebaseStorage
import CoreImage
import CoreGraphics
import Accelerate
import CoreImage.CIFilterBuiltins

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
    
    // Compression configuration
    private let targetFileSize: Int = 2000 * 1024  // Target 500KB
    private let maxDimension: CGFloat = 2200      // Max dimension 1800px
    private let compressionQuality: CGFloat = 0.9  // Initial compression quality
    
    // MARK: - Image Processing Methods
    
    private func compressImage(_ inputImage: UIImage) -> Data? {
        // Step 1: Resize the image while maintaining aspect ratio
        let resizedImage = resizeImage(inputImage)
        
        // Step 2: Compress the image with quality adjustment
        return compressImageData(resizedImage)
    }
    
    private func resizeImage(_ inputImage: UIImage) -> UIImage {
        let sourceSize = inputImage.size
        let maxDimension: CGFloat = 1800
        
        // Calculate scale factor to maintain aspect ratio
        let scaleFactor = maxDimension / max(sourceSize.width, sourceSize.height)
        
        // Only resize if the image is larger than our target
        guard scaleFactor < 1 else { return inputImage }
        
        let newWidth = sourceSize.width * scaleFactor
        let newHeight = sourceSize.height * scaleFactor
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        guard let cgImage = inputImage.cgImage else { return inputImage }
        
        // Use the original image's colorspace and bitmap info
        let originalColorSpace = cgImage.colorSpace ?? CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = cgImage.bitmapInfo
        
        // Configure vImage format with original image properties
        var format = vImage_CGImageFormat(
            bitsPerComponent: Int(cgImage.bitsPerComponent),
            bitsPerPixel: Int(cgImage.bitsPerPixel),
            colorSpace: originalColorSpace,
            bitmapInfo: bitmapInfo
        )
        
        guard var sourceBuffer = try? vImage_Buffer(cgImage: cgImage),
              var destinationBuffer = try? vImage_Buffer(width: Int(newWidth),
                                                         height: Int(newHeight),
                                                         bitsPerPixel: format!.bitsPerPixel) else {
            return inputImage
        }
        
        // High-quality resampling
        let error = vImageScale_ARGB8888(&sourceBuffer,
                                         &destinationBuffer,
                                         nil,
                                         vImage_Flags(kvImageHighQualityResampling))
        
        // Check for scaling errors
        guard error == kvImageNoError else {
            sourceBuffer.free()
            destinationBuffer.free()
            return inputImage
        }
        
        // Create resized image
        guard let resizedCGImage = try? destinationBuffer.createCGImage(format: format!) else {
            sourceBuffer.free()
            destinationBuffer.free()
            return inputImage
        }
        
        // Clean up
        sourceBuffer.free()
        destinationBuffer.free()
        
        // Preserve original image orientation and scale
        let resizedImage = UIImage(cgImage: resizedCGImage,
                                   scale: inputImage.scale,
                                   orientation: inputImage.imageOrientation)
        
        return resizedImage
    }
    
    private func compressImageData(_ image: UIImage) -> Data? {
        var compression: CGFloat = compressionQuality
        var data = image.jpegData(compressionQuality: compression)
        
        // Iteratively adjust compression until we're under target file size
        while data?.count ?? 0 > targetFileSize && compression > 0.1 {
            compression -= 0.1
            data = image.jpegData(compressionQuality: compression)
        }
        
        return data
    }
    
    // MARK: - Firebase Methods
    
    func deletePhoto(filename: String = "progressPic.jpg") async throws {
        let storageRef = Storage.storage().reference().child("\(taskPath)/\(filename)")
        do {
            try await storageRef.delete()
            selectedItem = nil
            selectedImageData = nil
            uploadProgress = 0.0
            uploadComplete = false
        } catch {
            do {
                let fileNamepng = "progressPic.png"
                let storageRefpng = Storage.storage().reference().child("\(taskPath)/\(fileNamepng)")
                try await storageRefpng.delete()
                selectedItem = nil
                selectedImageData = nil
                uploadProgress = 0.0
                uploadComplete = false
            } catch {
                throw error
            }
        }
    }
    
    // Convert selected image to compressed data
    func convertToCompressedData() -> Data? {
        guard let selectedImageData = selectedImageData,
              let uiImage = UIImage(data: selectedImageData) else {
            return nil
        }
        return compressImage(uiImage)
    }
    
    func getPhoto(filename: String = "progressPic.jpg") async throws -> Image {
        let storageRef = Storage.storage().reference().child("\(taskPath)/\(filename)")
        
        do {
            let imageData = try await storageRef.downloadData()
            
            guard let uiImage = UIImage(data: imageData) else {
                throw ImageRetrievalError.conversionFailed
            }
            
            return Image(uiImage: uiImage)
        } catch {
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
            throw error
        }
    }
    
    func uploadImageToFirebase() {
        guard let compressedData = convertToCompressedData() else {
            uploadError = NSError(domain: "PhotoUpload",
                                  code: 0,
                                  userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])
            return
        }
        
        let filename = "progressPic.jpg"
        let storageRef = Storage.storage().reference().child("\(taskPath)/\(filename)")
        
        // Create metadata to store compression information
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        metadata.customMetadata = [
            "originalWidth": "\(selectedImageData?.count ?? 0)",
            "compressedWidth": "\(compressedData.count)"
        ]
        
        let uploadTask = storageRef.putData(compressedData, metadata: metadata) { [weak self] metadata, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.uploadError = error
                    self.uploadComplete = false
                }
                return
            }
            
            DispatchQueue.main.async {
                self.uploadComplete = true
                self.uploadProgress = 1.0
            }
        }
        
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

struct OptimizedImageView: View {
    let image: Image
    
    var body: some View {
        image
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.quaternary)
            }
    }
}
