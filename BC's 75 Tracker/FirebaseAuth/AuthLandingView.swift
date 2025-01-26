//
//  AuthLandingView.swift
//  BC's 75 Tracker
//
//  Created by Bhavin Patel on 1/23/25.
//
import SwiftUI

struct AuthLandingView: View {
    
    @State private var firebase = FirebaseService()
    @State private var appManager = AppManager()
    var body: some View {
        NavigationStack(path: $appManager.path) {
            VStack(spacing: 40) {
                Text("Welcome")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 50)
                
                Spacer()
                
                // Create Account Button
                Button() {
                    appManager.path.append(.createAccount)
                } label: {
                    Text("Create Account")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue)
                        )
                }
                .padding(.horizontal)
                
                // Login Button
                Button() {
                    appManager.path.append(.signin)
                } label: {
                    Text("Login")
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .onChange(of: firebase.isLoggedIn, initial: true) {
                if firebase.isLoggedIn {
                    appManager.path.append(.chooseUser)
                }
            }
            .padding()
            .navigationTitle("")
            .navigationBarHidden(true)
            .navigationDestination(for: BCNavigation.self) {
                value in
                switch value {
                    case .calender(let userName):
                        CalendarView(userName: userName)
                    case .taskView(let userName, let date):
                        TaskView(userName: userName, date: date)
                    case .createAccount:
                        CreateAccountView()
                    case .signin:
                        SignInView()
                    case .chooseUser:
                        SidebarView()
                            .navigationBarBackButtonHidden()
                }
            }
        }
        .environment(firebase)
        .environment(appManager)
    }
}
