//
//  Firebase.swift
//  BC's 75 Tracker
//
//  Created by Bhavin Patel on 1/15/25.
//

import Firebase
import FirebaseDatabase

@Observable
class FirebaseService {
    private let db = Database.database().reference()
    var users: [String: User] = [:]
    
    init() {
        _Concurrency.Task {
            await loadUsers()
        }
    }
    
    private func fetchUsers() async throws -> [String: User] {
        do {
            let snapshot = try await db.child("users").getData()
            print(snapshot.value)
            print("1")
            guard let data = snapshot.value as? [String: Any] else { throw  BCError.failedToDecode1}
            print(data)
            print("2")
            let fetchedUsers: [String: User] = try data.compactMapValues { userDict in
                print(userDict)
                print("3")
                guard let jsonData = try? JSONSerialization.data(withJSONObject: userDict) else { throw BCError.failedToDecode1 }
                print("4")
                // Create a JSONDecoder with a custom date decoding strategy
                let decoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                return try decoder.decode(User.self, from: jsonData)
            }
            return fetchedUsers
        } catch {
            print(error)
            throw BCError.failedToDecode3
        }
        
    }
    
    private func loadUsers() async {
        do {
            let fetchedUsers = try await fetchUsers()
            users = fetchedUsers
        } catch {
            print(error)
        }
    }

    
    func updateTask(userName: String, date: String, task: Task) {
        let taskData = try? JSONEncoder().encode(task)
        guard let json = taskData.flatMap({ try? JSONSerialization.jsonObject(with: $0) }) else { return }
        db.child("users/\(userName)/Challenge75/Challenge1/tasks/\(date)").setValue(json)
    }
}


enum BCError: Error {
    case failedToDecode1
    case failedToDecode2
    case failedToDecode3
}
