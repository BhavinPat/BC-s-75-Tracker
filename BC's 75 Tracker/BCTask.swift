//
//  BCTask.swift
//  BC's 75 Tracker
//
//  Created by Bhavin Patel on 1/15/25.
//
import Foundation

struct Task: Codable, Equatable {
    var water: Bool
    var workout: Bool
    var reading: Bool
    var progressPic: Bool
    var food: Bool
    
    var completionPercentage: Double {
        let totalTasks = 5.0
        let completedTasks = [water, workout, reading, progressPic, food].filter { $0 }.count
        return (Double(completedTasks) / totalTasks)
    }
    
    init() {
        water = false
        workout = false
        reading = false
        progressPic = false
        food = false
    }
    
    
}

struct User: Codable {
    var startDate: Date
    var endDate: Date
    var tasks: [String: Task]
    
   
}
