//
//  TaskView.swift
//  BC's 75 Tracker
//
//  Created by Bhavin Patel on 1/15/25.
//
import SwiftUI
import Photos
import PhotosUI

struct TaskView: View {
    @Environment(FirebaseService.self) var firebase
    
    @State private var water: Double = 0
    @State private var workout: Bool = false
    @State private var reading: Bool = false
    @State private var progressPic: Bool = false
    @State private var food: Bool = false
    @State private var foodDescription: String = ""
    @State private var workoutDescription: String = ""
    
    @State private var progressPicImage: Image?
    
    @State private var photoModel: PhotoUploadViewModel = PhotoUploadViewModel()
    @State private var presentPhotoPicker: Bool = false
    @State private var didInitialLoad: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    
    
    @FocusState private var isTextEditorFocused: Bool
    
    var userName: String
    var date: String
    var challengeID: String
    
    private var isEditable: Bool {
        firebase.isChallengeActive(userName: userName, challengeID: challengeID)
    }
    
    //@Binding var tasks: [String: Task]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if !isEditable {
                    Label("This challenge is archived. You can view it, but editing is disabled.", systemImage: "lock.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
                
                // Water Intake Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Water Intake", systemImage: "drop.fill")
                            .font(.headline)
                        Text("\(Int(water))oz")
                            .font(.title2.bold())
                            .foregroundStyle(.secondary)
                        
                        Slider(
                            value: $water,
                            in: 0...100,
                            step: 5
                        ) {
                            Text("Water Intake")
                        } minimumValueLabel: {
                            Text("0")
                                .foregroundStyle(.secondary)
                        } maximumValueLabel: {
                            Text("100")
                                .foregroundStyle(.secondary)
                        }
                        .tint(.blue)
                    }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                }
                
                // Workout Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: $workout) {
                            Label("45 Min Workout", systemImage: "figure.run")
                                .font(.headline)
                        }
                        .tint(.green)
                        
                        if workout {
                            Text("Describe your workout")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            TextEditor(text: $workoutDescription)
                                .frame(height: 120)
                                .scrollContentBackground(.hidden)
                                .focused($isTextEditorFocused)
                                .background {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(uiColor: .tertiarySystemGroupedBackground))
                                }
                                .padding(.vertical, 8)
                        }
                    }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                }
                
                // Reading Section
                Section {
                    Toggle(isOn: $reading) {
                        Label("Read 10 Pages", systemImage: "book.fill")
                            .font(.headline)
                    }
                    .tint(.orange)
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                }
                
                // Progress Picture Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Progress Picture", systemImage: "camera.fill")
                            .font(.headline)
                        //if presentPhotoPicker {
                        if let image = progressPicImage {
                            VStack(spacing: 16) {
                                OptimizedImageView(image: image)
                                HStack(spacing: 12) {
                                    Button() {
                                        presentPhotoPicker.toggle()
                                    } label: {
                                        Text("Update Picture")
                                            .font(.subheadline.weight(.medium))
                                    }
                                    .buttonStyle(.bordered)
                                    
                                    Button(role: .destructive) {
                                        _Concurrency.Task {
                                            try await photoModel.deletePhoto()
                                            progressPicImage = nil
                                            progressPic = false
                                        }
                                    } label: {
                                        Text("Delete Picture")
                                            .font(.subheadline.weight(.medium))
                                    }
                                    .buttonStyle(.bordered)
                                }
                                
                            }
                        } else {
                            Button {
                                presentPhotoPicker.toggle()
                            } label: {
                                VStack {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.largeTitle)
                                    Text("Add Progress Picture")
                                        .font(.subheadline.weight(.medium))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                }
                
                // Food Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: $food) {
                            Label("Food Goal", systemImage: "fork.knife")
                                .font(.headline)
                        }
                        .tint(.purple)
                        
                        if food {
                            Text("Describe what you ate today")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            TextEditor(text: $foodDescription)
                                .frame(height: 120)
                                .scrollContentBackground(.hidden)
                                .focused($isTextEditorFocused)
                                .background {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(uiColor: .tertiarySystemGroupedBackground))
                                }
                                .padding(.vertical, 8)
                        }
                    }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                }
            }
            .padding()
            .disabled(!isEditable)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationBarTitleDisplayMode(.large)
        .scrollDismissesKeyboard(.interactively)
        .scrollBounceBehavior(.basedOnSize)
        .scrollIndicators(.hidden)
        .navigationTitle(formattedDateTask(date))
        .onChange(of: water) {
            guard isEditable, didInitialLoad else { return }
            saveTask()
        }
        .onChange(of: workout) {
            guard isEditable, didInitialLoad else { return }
            saveTask()
        }
        .onChange(of: reading) {
            guard isEditable, didInitialLoad else { return }
            saveTask()
        }
        .onChange(of: progressPic) {
            guard isEditable, didInitialLoad else { return }
            if (firebase.challenge(for: userName, challengeID: challengeID)?.tasks[date]?.progressPic ?? false) != progressPic {
                saveTask()
            }
        }
        .onChange(of: food) {
            guard isEditable, didInitialLoad else { return }
            saveTask()
        }
        .onChange(of: isTextEditorFocused) {
            guard isEditable, didInitialLoad, !isTextEditorFocused else { return }
            saveTask()
        }
        .onChange(of: photoModel.uploadComplete) {
            guard isEditable else { return }
            if photoModel.uploadComplete, let data = photoModel.selectedImageData {
                progressPicImage = Image(uiImage: UIImage(data: data)!)
                progressPic = true
            }
        }
        .onAppear {
            didInitialLoad = false
            
            photoModel.taskPath = "users/\(userName)/Challenge75/\(challengeID)/tasks/\(date)"
            _Concurrency.Task { @MainActor in
                do {
                    progressPicImage = try await photoModel.getPhoto()
                } catch {
                    print("Failed to get main photo: \(error.localizedDescription)")
                    do {
                        progressPicImage = try await photoModel.getPhoto(filename: "progressPic.png")
                    } catch {
                        print("Failed to get fallback photo: \(error.localizedDescription)")
                    }
                }
                progressPic = progressPicImage != nil
            }
            let existingTask = firebase.challenge(for: userName, challengeID: challengeID)?.tasks[date]
            water = existingTask?.water ?? 0.0
            foodDescription = existingTask?.foodDescription ?? ""
            workoutDescription = existingTask?.workoutDescription ?? ""
            workout = existingTask?.workout ?? false
            reading = existingTask?.reading ?? false
            food = existingTask?.food ?? false
            progressPic = existingTask?.progressPic ?? false
            didInitialLoad = true
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isTextEditorFocused = false // Dismiss keyboard
                }
            }
        }
        
        .sheet(isPresented: $presentPhotoPicker) {
            PhotoUploadView(viewModel: $photoModel)
                .presentationSizing(.form)
        }
        
        .animation(.easeInOut, value: isTextEditorFocused)
    }
    func formattedDateTask(_ date1: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: date1) else { return date1 }
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
    
    private func saveTask() {
        guard isEditable else { return }
        var task = Task()
        task.water = water
        task.workout = workout
        task.reading = reading
        task.progressPic = progressPic
        task.food = food
        task.workoutDescription = workoutDescription
        task.foodDescription = foodDescription
        firebase.updateTask(userName: userName, challengeID: challengeID, date: date, task: task)
    }
    
    func formatedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}
