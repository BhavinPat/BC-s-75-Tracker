//
//  SignInView.swift
//  BC's 75 Tracker
//
//  Created by Bhavin Patel on 1/23/25.
//

import SwiftUI

struct SignInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var emailError: Bool = false
    @State private var passwordError: Bool = false
    @State private var errorMessage: String = ""
    @Environment(FirebaseService.self) var firebase // ObservableObject for Firebase interactions
    @Environment(AppManager.self) var appManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome Back")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 10)
            
            Text("Sign in to your account")
                .foregroundColor(.gray)
            
            VStack(spacing: 15) {
                // Email TextField
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(emailError ? Color.red : Color.gray, lineWidth: 1))
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                
                // Password SecureField
                SecureField("Password", text: $password)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(passwordError ? Color.red : Color.gray, lineWidth: 1))
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
            }
            
            // Error message
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
            }
            
            // Continue Button
            Button(action: {
                handleSignIn()
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
            
            // Forgot Password
            Button(action: {
                firebase.resetPassword(for: email)
            }) {
                Text("Forgot Password?")
                    .foregroundColor(.blue)
                    .font(.subheadline)
            }
            .padding(.top, 5)
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .onChange(of: firebase.errorMessage) {
            if let error = firebase.errorMessage {
                self.errorMessage = error
                emailError = error.contains("email")
                passwordError = error.contains("password")
            } else {
                emailError = false
                passwordError = false
                errorMessage = ""
            }
        }
        .onChange(of: firebase.isLoggedIn) {
            if firebase.isLoggedIn {
                appManager.path.append(.chooseUser)
            }
        }
    }
    
    private func handleSignIn() {
        emailError = email.isEmpty
        passwordError = password.isEmpty
        
        if !emailError && !passwordError {
            firebase.signIn(email: email, password: password)
        } else {
            errorMessage = "Please fill out all fields."
        }
    }
}
