//
//  Firebase.swift
//  BC's 75 Tracker
//
//  Created by Bhavin Patel on 1/15/25.
//

import Firebase
import FirebaseDatabase
import FirebaseAuth

@Observable
class FirebaseService {
    private let db = Database.database().reference()
    var users: [String: User] = [:]
    var pTracker: [String: PMonth] = [:]
    
    private var challengeDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    /*
    init() {
        _Concurrency.Task {
            await load()
     }
     }
     */
    
    /// Fetch all poop tracking data from Firebase Realtime Database.
    private func fetchPoops() {
        let listener = db.child("pTracker").observe(.value, with: { [self]
            snapshot in
            guard let data = snapshot.value as? [String: Any] else { return }
            guard let jsonData = try? JSONSerialization.data(withJSONObject: data) else { return }
            let decoder = JSONDecoder()
            let poops = try? decoder.decode([String: PMonth].self, from: jsonData)
            if let poops {
                pTracker = poops
            }
        })
    }
    
    /// Fetch all users from Firebase Realtime Database.
    private func fetchUsers() {
        let listener = db.child("users").observe(.value, with: { [self]
            snapshot in
            guard let data = snapshot.value as? [String: Any] else {
                print("failed to get users")
                return
            }
            let fetchedUsers: [String: User] = try! data.compactMapValues { userDict in
                guard let jsonData = try? JSONSerialization.data(withJSONObject: userDict) else {
                    print("failed to decode")
                    throw BCError.failedToDecode1
                }
                // Create a JSONDecoder with a custom date decoding strategy
                do {
                    let decoder = JSONDecoder()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    decoder.dateDecodingStrategy = .formatted(dateFormatter)
                    return try decoder.decode(User.self, from: jsonData)
                } catch {
                    throw BCError.failedToDecode2
                }
            }
            print("fetched Users!!")
            users = fetchedUsers
            print(users)
        })
    }
    
    /// Load all necessary data (users and poop tracking).
    func load() {
        _Concurrency.Task {
            fetchUsers()
        }
        _Concurrency.Task {
            fetchPoops()
        }
    }
    
    /// Update poop tracking data for a given key.
    func updatePoops(key: String, value: PMonth) {
        let data = try? JSONEncoder().encode(value)
        guard let json = data.flatMap({ try? JSONSerialization.jsonObject(with: $0) }) else { return }
        db.child("pTracker/\(key)").setValue(json)
    }
    
    var lastCreatedChallengeID: String?
    
    func challenges(for userName: String) -> [(String, Challenge1)] {
        guard let challenge75 = users[userName]?.challenge75 else { return [] }
        let all = challenge75.allChallenges
        
        return all
            .map { ($0.key, $0.value) }
            .sorted {
                if $0.1.isActive != $1.1.isActive {
                    return $0.1.isActive
                }
                if $0.1.startDate != $1.1.startDate {
                    return $0.1.startDate > $1.1.startDate
                }
                return $0.0 < $1.0
            }
    }
    
    func challenge(for userName: String, challengeID: String) -> Challenge1? {
        users[userName]?.challenge75.challenge(for: challengeID)
    }
    
    func isChallengeActive(userName: String, challengeID: String) -> Bool {
        challenge(for: userName, challengeID: challengeID)?.isActive == true
    }
    
    /// Update a task for a user on a specific date under the selected Challenge75 challenge.
    func updateTask(userName: String, challengeID: String = "Challenge1", date: String, task: Task) {
        guard var challenge = challenge(for: userName, challengeID: challengeID), challenge.isActive else { return }
        challenge.tasks[date] = task
        setChallengeInMemory(userName: userName, challengeID: challengeID, challenge: challenge)
        
        let taskData = try? JSONEncoder().encode(task)
        guard let json = taskData.flatMap({ try? JSONSerialization.jsonObject(with: $0) }) else { return }
        db.child("users/\(userName)/Challenge75/\(challengeID)/tasks/\(date)").setValue(json)
    }
    
    func hasActiveChallenge(userName: String) -> Bool {
        challenges(for: userName).contains(where: { $0.1.isActive })
    }
    
    func startBlockedReason(participants: ChallengeParticipants) -> String? {
        let usersToUpdate = participants.userNames
        let activeUsers = usersToUpdate.filter { hasActiveChallenge(userName: $0) }
        
        if activeUsers.isEmpty {
            return nil
        }
        if activeUsers.count == 1, let firstUser = activeUsers.first {
            return "\(firstUser) already has an active 75 challenge. End it first."
        }
        return "Chloe and Bhavin already have active 75 challenges. End them first."
    }
    
    func startChallenge(participants: ChallengeParticipants) -> String? {
        if let blockedReason = startBlockedReason(participants: participants) {
            return blockedReason
        }
        
        let usersToUpdate = participants.userNames
        
        for userName in usersToUpdate where users[userName] == nil {
            return "Couldn't find \(userName) in Firebase users."
        }
        
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        guard let endDate = calendar.date(byAdding: .day, value: 74, to: startDate) else {
            return "Couldn't create challenge dates. Please try again."
        }
        
        let challengeID = nextChallengeID(for: usersToUpdate)
        let newChallenge = Challenge1(
            endDate: endDate,
            startDate: startDate,
            tasks: [:],
            isActive: true,
            participants: usersToUpdate
        )
        
        for userName in usersToUpdate {
            updateChallenge(userName: userName, challengeID: challengeID, challenge: newChallenge)
        }
        
        lastCreatedChallengeID = challengeID
        return nil
    }
    
    func endChallenge(userName: String, challengeID: String) -> String? {
        guard let selectedChallenge = challenge(for: userName, challengeID: challengeID) else {
            return "That challenge could not be found."
        }
        
        if !selectedChallenge.isActive {
            return "That challenge is already archived."
        }
        
        let targetUsers = selectedChallenge.participants.isEmpty ? [userName] : selectedChallenge.participants
        var didEndAnyChallenge = false
        
        for targetUser in targetUsers {
            guard var challengeToEnd = challenge(for: targetUser, challengeID: challengeID),
                  challengeToEnd.isActive else { continue }
            challengeToEnd.isActive = false
            updateChallenge(userName: targetUser, challengeID: challengeID, challenge: challengeToEnd)
            didEndAnyChallenge = true
        }
        
        if !didEndAnyChallenge {
            return "No active 75 challenge to end for that selection."
        }
        
        return nil
    }
    
    func endChallenge(participants: ChallengeParticipants) -> String? {
        let usersToUpdate = participants.userNames
        let activeUsers = usersToUpdate.filter { hasActiveChallenge(userName: $0) }
        
        if activeUsers.isEmpty {
            return "No active 75 challenge to end for that selection."
        }
        
        for userName in activeUsers {
            if let activeChallenge = challenges(for: userName).first(where: { $0.1.isActive }) {
                _ = endChallenge(userName: userName, challengeID: activeChallenge.0)
            }
        }
        
        return nil
    }
    
    private func setChallengeInMemory(userName: String, challengeID: String, challenge: Challenge1) {
        guard var user = users[userName] else { return }
        var challenge75 = user.challenge75
        challenge75.setChallenge(challenge, for: challengeID)
        user.challenge75 = challenge75
        users[userName] = user
    }
    
    private func updateChallenge(userName: String, challengeID: String, challenge: Challenge1) {
        setChallengeInMemory(userName: userName, challengeID: challengeID, challenge: challenge)
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(challengeDateFormatter)
        let challengeData = try? encoder.encode(challenge)
        guard let json = challengeData.flatMap({ try? JSONSerialization.jsonObject(with: $0) }) else { return }
        db.child("users/\(userName)/Challenge75/\(challengeID)").setValue(json)
    }
    
    private func nextChallengeID(for userNames: [String]) -> String {
        var maxIndex = 0
        
        for userName in userNames {
            guard let challengeKeys = users[userName]?.challenge75.allChallenges.keys else { continue }
            for key in challengeKeys where key.hasPrefix("Challenge") {
                let numericPart = key.replacingOccurrences(of: "Challenge", with: "")
                if let index = Int(numericPart) {
                    maxIndex = max(maxIndex, index)
                }
            }
        }
        
        if maxIndex == 0 {
            return "Challenge1"
        }
        
        return "Challenge\(maxIndex + 1)"
    }
    
    /// Update or create a PushUpTask for the specified user and date.
    func updatePushUpTask(userName: String, date: String, task: PushUpTask) {
        let taskData = try? JSONEncoder().encode(task)
        guard let json = taskData.flatMap({ try? JSONSerialization.jsonObject(with: $0) }) else { return }
        db.child("users/\(userName)/PushUpTasks/\(date)").setValue(json)
    }
    
    var errorMessage: String?
    
    // MARK: - Authentication
    
    /// Sign in with email and password.
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.errorMessage = nil
                    self?.isLoggedIn = true
                }
            }
        }
    }
    
    /// Create a new account with email and password.
    func createAccount(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(false, error)
                return
            }
            
            self.isLoggedIn = true
            completion(true, nil)
        }
    }
    
    /// Reset password for a given email address.
    func resetPassword(for email: String) {
        guard !email.isEmpty else {
            self.errorMessage = "Please enter your email address."
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.errorMessage = "Password reset email sent."
                }
            }
        }
    }
    
    var isLoggedIn: Bool = false // Published property to monitor login status
    var user: FirebaseAuth.User? = nil // Store user info
    
    init() {
        self.listenToAuthState()
    }
    
    /// Listen to Firebase Auth State Changes.
    private func listenToAuthState() {
        let _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user = user {
                    self?.isLoggedIn = true
                    self?.user = user
                } else {
                    self?.isLoggedIn = false
                    self?.user = nil
                }
            }
        }
    }
    
    /// Check if the user is logged in.
    func checkLoginStatus() -> Bool {
        return isLoggedIn
    }
    
    /// Log out the user.
    func logout() throws {
        do {
            try Auth.auth().signOut()
        } catch {
            throw error
        }
    }
}

enum BCError: Error {
    case failedToDecode1
    case failedToDecode2
    case failedToDecode3
}
