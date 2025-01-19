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
    
    private func fetchUsers(completion: @escaping ([String: User]) -> Void) {
        db.child("users").getData(completion: { error, snapshot in
        //db.child("users").observeSingleEvent(of: .value) { snapshot, _ in
            
            guard let snapshot, let data = snapshot.value as? [String: Any] else { return }
            
            let fetchedUsers: [String: User] = data.compactMapValues { userDict in
                guard let jsonData = try? JSONSerialization.data(withJSONObject: userDict) else { return nil }
                
                // Create a JSONDecoder with a custom date decoding strategy
                let decoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                return try? decoder.decode(User.self, from: jsonData)
            }
            
            //print(fetchedUsers)
            completion(fetchedUsers)
        })
    }
    
    private func loadUsers() async {
        let fetchedUsers = await withCheckedContinuation { continuation in
            fetchUsers { messages in
                continuation.resume(returning: messages)
            }
        }
        users = fetchedUsers
    }

    
    func updateTask(userName: String, date: String, task: Task) {
        let taskData = try? JSONEncoder().encode(task)
        guard let json = taskData.flatMap({ try? JSONSerialization.jsonObject(with: $0) }) else { return }
        db.child("users/\(userName)/tasks/\(date)").setValue(json)
    }
}
