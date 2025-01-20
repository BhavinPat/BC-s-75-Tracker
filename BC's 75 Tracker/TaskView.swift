//
//  TaskView.swift
//  BC's 75 Tracker
//
//  Created by Bhavin Patel on 1/15/25.
//
import SwiftUI

struct TaskView: View {
    @Environment(FirebaseService.self) var firebase
    
    @State private var water: Bool = false
    @State private var workout: Bool = false
    @State private var reading: Bool = false
    @State private var progressPic: Bool = false
    @State private var food: Bool = false
    
    var userName: String
    var date: String
    
    //@Binding var tasks: [String: Task]
    
    var body: some View {
        List {
            Button {
                water.toggle()
            } label: {
                if !water {
                    Label("3L of Water", systemImage: "square")
                } else {
                    Label("3L of Water", systemImage: "checkmark")
                        .symbolVariant(.square)
                }
            }
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
        .onAppear {
            water = firebase.users[userName]?.Challenge75.Challenge1.tasks[date]?.water ?? false
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
