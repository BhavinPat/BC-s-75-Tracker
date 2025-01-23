//
//  TaskView.swift
//  BC's 75 Tracker
//
//  Created by Bhavin Patel on 1/15/25.
//
import SwiftUI

struct TaskView: View {
    @Environment(FirebaseService.self) var firebase
    
    @State private var water: Double = 0
    @State private var workout: Bool = false
    @State private var reading: Bool = false
    @State private var progressPic: Bool = false
    @State private var food: Bool = false
    @State private var foodDescription: String = ""
    @State private var workoutDescription: String = ""
    
    var userName: String
    var date: String
    
    //@Binding var tasks: [String: Task]
    
    var body: some View {
        List {
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
                    workout.toggle()
                } label: {
                    if !workout {
                        Label("45 Min Workout", systemImage: "square")
                    } else {
                        Label("45 Min Workout", systemImage: "checkmark")
                            .symbolVariant(.square)
                    }
                }
                if workout {
                    Text("Describe your workout")
                    TextEditor(text: $workoutDescription)
                }
            }
            Button {
                reading.toggle()
            } label: {
                if !reading {
                    Label("Read 10 Pages", systemImage: "square")
                } else {
                    Label("Read 10 Pages", systemImage: "checkmark")
                        .symbolVariant(.square)
                }
            }
            Button {
                progressPic.toggle()
            } label: {
                if !progressPic {
                    Label("Progress Pic", systemImage: "square")
                } else {
                    Label("Progress Pic", systemImage: "checkmark")
                        .symbolVariant(.square)
                }
            }
            Group {
                Button {
                    food.toggle()
                } label: {
                    if !food {
                        Label("Food Goal", systemImage: "square")
                    } else {
                        Label("Food Goal", systemImage: "checkmark")
                            .symbolVariant(.square)
                    }
                }
                if food {
                    Text("Describe what you ate today")
                    TextEditor(text: $foodDescription)
                }
            }
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
            firebase.users[userName]?.Challenge75.Challenge1.tasks[date]?.progressPic = progressPic
            saveTask()
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
        .onAppear {
            water = firebase.users[userName]?.Challenge75.Challenge1.tasks[date]?.water ?? 0.0
            foodDescription = firebase.users[userName]?.Challenge75.Challenge1.tasks[date]?.foodDescription ?? ""
            workoutDescription = firebase.users[userName]?.Challenge75.Challenge1.tasks[date]?.workoutDescription ?? ""
            workout = firebase.users[userName]?.Challenge75.Challenge1.tasks[date]?.workout ?? false
            reading = firebase.users[userName]?.Challenge75.Challenge1.tasks[date]?.reading ?? false
            progressPic = firebase.users[userName]?.Challenge75.Challenge1.tasks[date]?.progressPic ?? false
            food = firebase.users[userName]?.Challenge75.Challenge1.tasks[date]?.food ?? false
        }
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
