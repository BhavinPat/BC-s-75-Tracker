//
//  PhotoUploadView.swift
//  BC's 75 Tracker
//
//  Created by Bhavin Patel on 1/26/25.
//
import SwiftUI
import Photos

struct PhotoUploadView: View {
    @Binding var viewModel: PhotoUploadViewModel
    @State private var presentPhotoPicker = false
    var body: some View {
        VStack {
            // Button to open PhotoPicker
            Button("Select Photo") {
                viewModel.selectedItem = nil
                viewModel.selectedImageData = nil
                presentPhotoPicker = true
            }
            .photosPicker(isPresented: $presentPhotoPicker,
                          selection: $viewModel.selectedItem,
                          matching: .images)
            
            // Display selected image
            if let selectedData = viewModel.selectedImageData,
                let uiImage = UIImage(data: selectedData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                
                // Confirmation Buttons
                HStack {
                    Button("Confirm Upload") {
                        viewModel.uploadImageToFirebase()
                    }
                    
                    Button("Cancel Upload") {
                        viewModel.selectedItem = nil
                        viewModel.selectedImageData = nil
                    }
                }
            }
            
            // Upload Progress
            if viewModel.uploadProgress > 0 {
                ProgressView(value: viewModel.uploadProgress)
                    .progressViewStyle(LinearProgressViewStyle())
            }
            
            // Upload Status
            if viewModel.uploadComplete {
                Text("Upload Successful!")
                    .foregroundColor(.green)
            }
            
            // Error Handling
            if let error = viewModel.uploadError {
                Text("Upload Failed: \(error.localizedDescription)")
                    .foregroundColor(.red)
            }
        }
        // PhotosPicker onChange handler
        .onChange(of: viewModel.selectedItem) {
            _Concurrency.Task {
                // Load selected image data
                if let data = try? await viewModel.selectedItem?.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        viewModel.selectedImageData = data
                    }
                }
            }
        }
    }
}
