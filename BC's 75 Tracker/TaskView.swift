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
    
    @Environment(\.colorScheme) var colorScheme
    
    
    @FocusState private var isTextEditorFocused: Bool
    
    var userName: String
    var date: String
    
    //@Binding var tasks: [String: Task]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
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
                        
                        if let image = progressPicImage {
                            image
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(.quaternary)
                                }
                            
                            Button {
                                presentPhotoPicker.toggle()
                            } label: {
                                Text("Update Picture")
                                    .font(.subheadline.weight(.medium))
                            }
                            .buttonStyle(.bordered)
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
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationBarTitleDisplayMode(.large)
        .scrollDismissesKeyboard(.interactively)
        .scrollBounceBehavior(.basedOnSize)
        .scrollIndicators(.hidden)
        .navigationTitle(formattedDateTask(date))
        .onChange(of: water) {
            firebase.users[userName]?.Challenge75.Challenge1.tasks[date]?.water = water
            saveTask()
            //onUpdate(firebase.currentTask)
        }
        .onChange(of: workout) {
            firebase.users[userName]?.Challenge75.Challenge1.tasks[date]?.workout = workout
            saveTask()
            //onUpdate(firebase.currentTask)
        }
        .onChange(of: reading) {
            firebase.users[userName]?.Challenge75.Challenge1.tasks[date]?.reading = reading
            saveTask()
            //onUpdate(firebase.currentTask)
        }
        .onChange(of: progressPic) {
            if firebase.users[userName]?.Challenge75.Challenge1.tasks[date]?.progressPic != progressPic {
                firebase.users[userName]?.Challenge75.Challenge1.tasks[date]?.progressPic = progressPic
                saveTask()
            }
            // onUpdate(firebase.currentTask)
        }
        .onChange(of: food) {
            firebase.users[userName]?.Challenge75.Challenge1.tasks[date]?.food = food
            saveTask()
            //onUpdate(firebase.currentTask)
        }
        .onChange(of: isTextEditorFocused) {
            firebase.users[userName]?.Challenge75.Challenge1.tasks[date]?.workoutDescription = workoutDescription
            firebase.users[userName]?.Challenge75.Challenge1.tasks[date]?.foodDescription = foodDescription
            saveTask()
        }
        .onChange(of: photoModel.uploadComplete) {
            
            if photoModel.uploadComplete, let data = photoModel.selectedImageData {
                progressPicImage = Image(uiImage: UIImage(data: data)!)
                progressPic = true
            }
            
        }
        .onAppear {
            
            photoModel.taskPath = "users/\(userName)/Challenge75/Challenge1/tasks/\(date)"
            _Concurrency.Task {
                do {
                    progressPicImage = try await photoModel.getPhoto()
                    progressPic = true
                } catch {
                    progressPic = false
                }
            }
            water = firebase.users[userName]?.Challenge75.Challenge1.tasks[date]?.water ?? 0.0
            foodDescription = firebase.users[userName]?.Challenge75.Challenge1.tasks[date]?.foodDescription ?? ""
            workoutDescription = firebase.users[userName]?.Challenge75.Challenge1.tasks[date]?.workoutDescription ?? ""
            workout = firebase.users[userName]?.Challenge75.Challenge1.tasks[date]?.workout ?? false
            reading = firebase.users[userName]?.Challenge75.Challenge1.tasks[date]?.reading ?? false
            food = firebase.users[userName]?.Challenge75.Challenge1.tasks[date]?.food ?? false
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
        let date = dateFormatter.date(from: date1)!
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
    
    private func saveTask() {
        //firebase.users[userName]?.tasks[date] = task
        firebase.updateTask(userName: userName, date: date, task: (firebase.users[userName]?.Challenge75.Challenge1.tasks[date])!)
        //tasks[date] = task
    }
    
    func formatedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}
