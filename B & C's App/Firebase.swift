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
    /*
    init() {
        _Concurrency.Task {
            await load()
     }
     }
     */
    
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
                let decoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                return try? decoder.decode(User.self, from: jsonData)
            }
            print(users)
            print("fetched Users!!")
            users = fetchedUsers
        })
    }
    
    func load() {
        _Concurrency.Task {
            fetchUsers()
        }
        _Concurrency.Task {
            fetchPoops()
        }
    }
    
    func updatePoops(key: String, value: PMonth) {
        let data = try? JSONEncoder().encode(value)
        guard let json = data.flatMap({ try? JSONSerialization.jsonObject(with: $0) }) else { return }
        db.child("pTracker/\(key)").setValue(json)
    }

    
    func updateTask(userName: String, date: String, task: Task) {
        let taskData = try? JSONEncoder().encode(task)
        guard let json = taskData.flatMap({ try? JSONSerialization.jsonObject(with: $0) }) else { return }
        db.child("users/\(userName)/Challenge75/Challenge1/tasks/\(date)").setValue(json)
    }
    
    
    var errorMessage: String?
    
    // Sign in with email and password
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
    
    // Reset password
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
    
    /// Listen to Firebase Auth State Changes
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
    
    /// Check if the user is logged in
    func checkLoginStatus() -> Bool {
        return isLoggedIn
    }
    
    /// Log out the user
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
