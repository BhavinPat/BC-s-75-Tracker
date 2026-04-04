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
    var challenge75: Challenge75
    // Flat dictionary of push-up tasks keyed by date string
    var pushUpTasks: [String: PushUpTask] = [:]
    
    enum CodingKeys: String, CodingKey {
        case challenge75 = "Challenge75"
        case pushUpTasks = "PushUpTasks"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        challenge75 = try container.decode(Challenge75.self, forKey: .challenge75)
        pushUpTasks = (try? container.decode([String: PushUpTask].self, forKey: .pushUpTasks)) ?? [:]
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(challenge75, forKey: .challenge75)
        try container.encode(pushUpTasks, forKey: .pushUpTasks)
    }
}

struct Challenge75: Codable {
    typealias ChallengeModel = Challenge1

    var Challenge1: ChallengeModel
    var additionalChallenges: [String: ChallengeModel] = [:]
    
    enum CodingKeys: String, CodingKey {
        case Challenge1 = "Challenge1"
    }
    
    private struct DynamicCodingKey: CodingKey {
        var stringValue: String
        init?(stringValue: String) { self.stringValue = stringValue }
        
        var intValue: Int?
        init?(intValue: Int) { return nil }
    }
    
    init(Challenge1: ChallengeModel, additionalChallenges: [String: ChallengeModel] = [:]) {
        self.Challenge1 = Challenge1
        self.additionalChallenges = additionalChallenges
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKey.self)
        var decodedChallenges: [String: ChallengeModel] = [:]
        
        for key in container.allKeys where key.stringValue.hasPrefix("Challenge") {
            if let challenge = try? container.decode(ChallengeModel.self, forKey: key) {
                decodedChallenges[key.stringValue] = challenge
            }
        }
        
        if let challenge1 = decodedChallenges.removeValue(forKey: "Challenge1") {
            Challenge1 = challenge1
        } else if let firstChallenge = decodedChallenges.sorted(by: { $0.key < $1.key }).first?.value {
            Challenge1 = firstChallenge
        } else {
            Challenge1 = .init(endDate: Date(), startDate: Date(), tasks: [:], isActive: false, participants: [])
        }
        
        additionalChallenges = decodedChallenges
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKey.self)
        
        if let key = DynamicCodingKey(stringValue: "Challenge1") {
            try container.encode(Challenge1, forKey: key)
        }
        
        for keyName in additionalChallenges.keys.sorted() {
            guard let key = DynamicCodingKey(stringValue: keyName),
                  let challenge = additionalChallenges[keyName] else { continue }
            try container.encode(challenge, forKey: key)
        }
    }
    
    var allChallenges: [String: ChallengeModel] {
        var all = additionalChallenges
        all["Challenge1"] = Challenge1
        return all
    }
    
    func challenge(for challengeID: String) -> ChallengeModel? {
        if challengeID == "Challenge1" {
            return Challenge1
        }
        return additionalChallenges[challengeID]
    }
    
    mutating func setChallenge(_ challenge: ChallengeModel, for challengeID: String) {
        if challengeID == "Challenge1" {
            Challenge1 = challenge
        } else {
            additionalChallenges[challengeID] = challenge
        }
    }
}

struct Challenge1: Codable {
    var endDate: Date
    var startDate: Date
    var tasks: [String: Task]
    var isActive: Bool
    var participants: [String]
    
    enum CodingKeys: String, CodingKey {
        case endDate
        case startDate
        case tasks
        case isActive
        case participants
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        endDate = try container.decode(Date.self, forKey: .endDate)
        startDate = try container.decode(Date.self, forKey: .startDate)
        tasks = (try? container.decode([String: Task].self, forKey: .tasks)) ?? [:] // Default to empty dictionary
        if let decodedIsActive = try? container.decode(Bool.self, forKey: .isActive) {
            isActive = decodedIsActive
        } else {
            // Backward-compatible fallback for older data without an explicit active flag.
            let today = Calendar.current.startOfDay(for: Date())
            isActive = endDate >= today
        }
        participants = (try? container.decode([String].self, forKey: .participants)) ?? []
    }
    
    init(endDate: Date, startDate: Date, tasks: [String: Task], isActive: Bool, participants: [String]) {
        self.endDate = endDate
        self.startDate = startDate
        self.tasks = tasks
        self.isActive = isActive
        self.participants = participants
    }
}

enum ChallengeParticipants: String, CaseIterable, Identifiable {
    case chloe = "Chloe"
    case bhavin = "Bhavin"
    case both = "Both"
    
    var id: String { rawValue }
    
    var userNames: [String] {
        switch self {
        case .chloe:
            return ["Chloe"]
        case .bhavin:
            return ["Bhavin"]
        case .both:
            return ["Chloe", "Bhavin"]
        }
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

// Assuming PushUpTask is defined somewhere else in the codebase
