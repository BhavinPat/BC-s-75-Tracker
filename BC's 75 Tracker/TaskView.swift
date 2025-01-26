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
            VStack(alignment: .leading) {
                Group {
                    Text("Water Intake: \(Int(water))oz")
                    Slider(
                        value: $water,
                        in: 0...100,
                        step: 5
                    ) {
                        Text("Water Intake")
                    } minimumValueLabel: {
                        Text("0oz")
                    } maximumValueLabel: {
                        Text("100oz")
                    } onEditingChanged: { editing in
                        //isEditing = editing
                    }
                }
                Group {
                    Button {
                        withAnimation {
                            workout.toggle()
                        }
                    } label: {
                        if !workout {
                            Label("45 Min Workout", systemImage: "square")
                                .labelStyle(.titleAndIcon)
                                .foregroundStyle(colorScheme == .dark ? .white:.black)
                        } else {
                            Label("45 Min Workout", systemImage: "checkmark")
                                .symbolVariant(.square)
                                .labelStyle(.titleAndIcon)
                                .foregroundStyle(colorScheme == .dark ? .white:.black)
                        }
                    }
                    if workout {
                        Text("Describe your workout:")
                        TextEditor(text: $workoutDescription)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(Color.primary.opacity(0.2), lineWidth: 1)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(UIColor.secondarySystemBackground))
                                    )
                            )
                            .focused($isTextEditorFocused)
                            .frame(height: 200)
                            .padding()
                    }
                }
                Button {
                    withAnimation {
                        reading.toggle()
                    }
                } label: {
                    if !reading {
                        Label("Read 10 Pages", systemImage: "square")
                            .labelStyle(.titleAndIcon)
                            .foregroundStyle(colorScheme == .dark ? .white:.black)
                    } else {
                        Label("Read 10 Pages", systemImage: "checkmark")
                            .labelStyle(.titleAndIcon)
                            .foregroundStyle(colorScheme == .dark ? .white:.black)
                            .symbolVariant(.square)
                    }
                }
                
                if let image = progressPicImage {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                    Button {
                        presentPhotoPicker.toggle()
                    } label: {
                        Text("Update Progress Pic")
                    }
                } else {
                    Button {
                        presentPhotoPicker.toggle()
                    } label: {
                        Text("Add Progress Pic")
                    }
                }
                
                Group {
                    Button {
                        withAnimation {
                            food.toggle()
                        }
                    } label: {
                        if !food {
                            Label("Food Goal", systemImage: "square")
                                .labelStyle(.titleAndIcon)
                                .foregroundStyle(colorScheme == .dark ? .white:.black)
                        } else {
                            Label("Food Goal", systemImage: "checkmark")
                                .labelStyle(.titleAndIcon)
                                .foregroundStyle(colorScheme == .dark ? .white:.black)
                                .symbolVariant(.square)
                        }
                    }
                    if food {
                        Text("Describe what you ate today:")
                        TextEditor(text: $foodDescription)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(Color.primary.opacity(0.2), lineWidth: 1)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(UIColor.secondarySystemBackground))
                                    )
                            )
                            .focused($isTextEditorFocused)
                            .frame(height: 200) // Adjust height as needed
                            .padding()
                        
                    }
                }
                Spacer()
            }
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
            .onChange(of: workoutDescription) {
                firebase.users[userName]?.Challenge75.Challenge1.tasks[date]?.workoutDescription = workoutDescription
                saveTask()
            }
            .onChange(of: foodDescription) {
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
        .scrollDismissesKeyboard(.interactively)
        .scrollBounceBehavior(.basedOnSize)
        .scrollIndicators(.hidden)
        .navigationTitle(formattedDateTask(date))
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
