//
//  PhotoUploadView.swift
//  BC's 75 Tracker
//
//  Created by Bhavin Patel on 1/26/25.
//
import SwiftUI
import Photos
import PhotosUI

struct PhotoUploadView: View {
    @Binding var viewModel: PhotoUploadViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var presentPhotoPicker = false
    
    var body: some View {
        //NavigationStack??????????????
        VStack(spacing: 24) {
            // Main Photo Section
            Group {
                if let selectedData = viewModel.selectedImageData,
                   let uiImage = UIImage(data: selectedData) {
                    // Selected Image Preview
                    VStack(spacing: 16) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(.quaternary)
                            }
                            .frame(maxHeight: 300)
                            .padding(.horizontal)
                        
                        // Action Buttons
                        HStack(spacing: 16) {
                            Button(role: .destructive) {
                                viewModel.selectedItem = nil
                                viewModel.selectedImageData = nil
                            } label: {
                                Label("Cancel", systemImage: "xmark.circle.fill")
                            }
                            .buttonStyle(.bordered)
                            
                            Button {
                                viewModel.uploadImageToFirebase()
                            } label: {
                                Label("Upload Photo", systemImage: "arrow.up.circle.fill")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                } else {
                    // Photo Selection Button
                    PhotosPicker(selection: $viewModel.selectedItem,
                                 matching: .images) {
                        VStack(spacing: 12) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 40))
                                .foregroundStyle(.tint)
                            
                            Text("Select Photo")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                        }
                        .contentShape(Rectangle())
                    }
                }
            }
            
            // Upload Progress & Status
            if viewModel.uploadProgress > 0 && !viewModel.uploadComplete {
                VStack(spacing: 8) {
                    ProgressView(value: viewModel.uploadProgress) {
                        Text("Uploading...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .tint(.blue)
                    
                    Text("\(Int(viewModel.uploadProgress * 100))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                }
            }
            
            // Success Message
            if viewModel.uploadComplete {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Photo uploaded successfully!")
                        .font(.subheadline)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                }
            }
            
            // Error Message
            if let error = viewModel.uploadError {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                    Text(error.localizedDescription)
                        .font(.subheadline)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.red.opacity(0.2))
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding()
        .navigationTitle("Upload Photo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .automatic) {
                Button("Done") {
                    dismiss()
                }
                .disabled(!viewModel.uploadComplete)
            }
        }
        .onChange(of: viewModel.selectedItem) {
            _Concurrency.Task {
                if let data = try? await viewModel.selectedItem?.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        viewModel.selectedImageData = data
                    }
                }
            }
        }
        .onChange(of: viewModel.uploadComplete) {
            if viewModel.uploadComplete {
                // Add a small delay before dismissing to show the success message
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            }
        }
    }
    
}
