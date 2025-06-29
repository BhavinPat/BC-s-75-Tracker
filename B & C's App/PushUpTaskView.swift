//
//  PushUpTaskView.swift
//  BC's 75 Tracker
//
//  Created by Bhavin Patel on 6/29/25.
//

import SwiftUI

struct PushUpTaskView: View {
    @Environment(FirebaseService.self) var firebase
    
    @State private var completed: Double = 0
    @State private var goal: Double = 50
    
    var userName: String
    var date: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Push-Ups", systemImage: "figure.strengthtraining.traditional")
                        .font(.headline)
                    HStack {
                        Text("\(Int(completed)) / \(Int(goal)) pushups")
                            .font(.title2.bold())
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int(completionPercentage * 100))%")
                            .font(.callout.bold())
                            .foregroundStyle(completionPercentage >= 1.0 ? .green : .orange)
                    }
                    Slider(
                        value: $completed,
                        in: 0...goal,
                        step: 1
                    ) {
                        Text("Push-Ups Completed")
                    } minimumValueLabel: {
                        Text("0")
                            .foregroundStyle(.secondary)
                    } maximumValueLabel: {
                        Text("\(Int(goal))")
                            .foregroundStyle(.secondary)
                    }
                    .tint(.purple)
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
            }
            Spacer()
        }
        .padding()
        
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle(formattedDateTask(date))
        .onChange(of: completed) { newValue in
            saveTask()
        }
        .onAppear {
            let puTask = firebase.users[userName]?.pushUpTasks[date] ?? PushUpTask()
            completed = Double(puTask.completed)
            goal = Double(puTask.goal)
        }
        .animation(.easeInOut, value: completed)
    }
    
    private var completionPercentage: Double {
        guard goal > 0 else { return 0.0 }
        return min(completed / goal, 1.0)
    }
    
    private func formattedDateTask(_ date1: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: date1) ?? Date()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
    
    private func saveTask() {
        let task = PushUpTask(goal: Int(goal), completed: Int(completed))
        firebase.users[userName]?.pushUpTasks[date] = task
        firebase.updatePushUpTask(userName: userName, date: date, task: task)
    }
}
