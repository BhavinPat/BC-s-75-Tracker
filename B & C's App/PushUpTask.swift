//
//  PushUpTask.swift
//  B & C's App
//
//  Created by Bhavin Patel on 4/6/25.
//

import Foundation

struct PushUpTask: Codable {
    var goal: Int
    var completed: Int
    
    init(goal: Int = 50, completed: Int = 0) {
        self.goal = goal
        self.completed = completed
    }

    var completionPercentage: Double {
        guard goal > 0 else { return 0.0 }
        return min(Double(completed) / Double(goal), 1.0)
    }
}
