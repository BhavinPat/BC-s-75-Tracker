//
//  BCTask.swift
//  BC's 75 Tracker
//
//  Created by Bhavin Patel on 1/15/25.
//
import Foundation


struct Root: Codable {
    var users: [String: User]
}

struct User: Codable {
    var Challenge75: Challenge75
    //var PushUpChallenge: [PushUpChallenge]
    
    enum CodingKeys: String, CodingKey {
        case Challenge75 = "Challenge75"
        //case PushUpChallenge = "PushUpChallenge"
    }
}

struct Challenge75: Codable {
    var Challenge1: Challenge1
    
    enum CodingKeys: String, CodingKey {
        case Challenge1 = "Challenge1"
    }
}

struct Challenge1: Codable {
    var endDate: Date
    var startDate: Date
    var tasks: [String: Task]
    
    enum CodingKeys: String, CodingKey {
        case endDate
        case startDate
        case tasks
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        endDate = try container.decode(Date.self, forKey: .endDate)
        startDate = try container.decode(Date.self, forKey: .startDate)
        tasks = (try? container.decode([String: Task].self, forKey: .tasks)) ?? [:] // Default to empty dictionary
    }
}

struct Task: Codable, Equatable {

    
    var water: Double
    var workout: Bool
    var reading: Bool
    var progressPic: Bool
    var food: Bool
    var workoutDescription: String
    var foodDescription: String
    
    var completionPercentage: Double {
        let totalTasks = 5.0
        var completedTasks: Double = Double([workout, reading, progressPic, food].filter { $0 }.count)
        var water = self.water/100.0
        if water > 100 {
            water = 100
        }
        completedTasks += water
        return (completedTasks / totalTasks)
    }
    
    init() {
        water = 0
        workout = false
        reading = false
        progressPic = false
        food = false
        workoutDescription = ""
        foodDescription = ""
    }
}
