//
//  CreateAccountView.swift
//  BC's 75 Tracker
//
//  Created by Bhavin Patel on 1/23/25.
//


import SwiftUI

struct CreateAccountView: View {
    @Environment(FirebaseService.self) var firebase
    @Environment(AppManager.self) var appManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.largeTitle)
                .bold()
            
            // Email Field
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(email.isValidEmail() ? Color.gray : Color.red, lineWidth: 1)
                )
                .overlay(
                    Text(email.isValidEmail() ? "" : "Invalid email")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding([.top, .trailing], 5),
                    alignment: .bottomTrailing
                )
            
            // Password Field
            SecureField("Password", text: $password)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(password.isEmpty || password.count >= 6 ? Color.gray : Color.red, lineWidth: 1)
                )
            
            // Confirm Password Field
            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(passwordsMatch() ? Color.gray : Color.red, lineWidth: 1)
                )
                .overlay(
                    Text(passwordsMatch() ? "" : "Passwords do not match")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding([.top, .trailing], 5),
                    alignment: .bottomTrailing
                )
            
            // Error Message
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Create Account Button
            Button(action: createAccount) {
                Text("Create Account")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue)
                    )
            }
            .padding(.top, 10)
            .disabled(!formIsValid())
            .opacity(formIsValid() ? 1.0 : 0.5)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Create Account")
        .onChange(of: firebase.isLoggedIn) {
            if firebase.isLoggedIn {
                appManager.path.append(.chooseUser)
            }
        }
    }
    
    private func createAccount() {
        guard formIsValid() else {
            errorMessage = "Please fill out all fields correctly."
            return
        }
        
        firebase.createAccount(email: email, password: password) { success, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else if success {
                errorMessage = ""
            }
        }
    }
    
    private func passwordsMatch() -> Bool {
        return password == confirmPassword && !password.isEmpty
    }
    
    private func formIsValid() -> Bool {
        return email.isValidEmail() && passwordsMatch() && password.count >= 6
    }
}

// MARK: - Email Validation Extension
extension String {
    func isValidEmail() -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,64}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
}
