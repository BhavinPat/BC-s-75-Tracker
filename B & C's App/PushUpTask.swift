//
//  PushUpTask.swift
//  B & C's App
//
//  Created by Bhavin Patel on 4/6/25.
//

import Foundation

struct pushUpTask: Codable {
    var pushUps: Int
    
    func completionPercentage(goal: Int) -> Double {
        return Double(pushUps) / Double(goal)
    }
    
}

struct PushUpChallenge: Codable {
    var endDate: Date
    var startDate: Date
    var pushUpGoal: Int
    var tasks: [String: pushUpTask]
    
    enum CodingKeys: String, CodingKey {
        case endDate
        case startDate
        case tasks
        case pushUpGoal
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        endDate = try container.decode(Date.self, forKey: .endDate)
        startDate = try container.decode(Date.self, forKey: .startDate)
        tasks = (try? container.decode([String: pushUpTask].self, forKey: .tasks)) ?? [:] // Default to empty dictionary
        pushUpGoal = try container.decode(Int.self, forKey: .pushUpGoal)
    }
}
