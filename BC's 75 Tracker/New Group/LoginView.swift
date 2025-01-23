//
//  LoginView.swift
//  FlightPath And NeuroDNA
//
//  Created by Bhavin Patel on 1/30/23.
//

import SwiftUI
import FirebaseAuth
///There is a bug where navigation (dismiss and push) fail. Causing a huge memory leak. This occcures when a firebase auth signin or createuser completes and the view attempts to dismiss itself.
///There doesnt seem to be a fix that i can identifty. I will be returning to UIKIt for actions that utilize completion functions for Firebase Auth. maybe in the future this code can be put to use. lost 2 days of work :(
struct LoginView: View {
    @State private var emailAddress = ""
    @State private var password = ""
    @State private var errorString = ""
    @State private var displayError = false
    @Binding  var isLoggedin: Bool
    @State private var authHandler: AuthStateDidChangeListenerHandle!
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View {
        VStack() {
            if displayError {
                Text(errorString)
                    .font(.system(size: 15))
                    .padding(.vertical, 30)
            }
            Group {
                HStack {
                    Text("Email")
                        .font(.system(size: 15.0))
                        .padding(.bottom, 6.0)
                    Spacer()
                }
                CustomTextFieldView(text: $emailAddress, labelText: "Email")
                    .frame(height: 44.0)
                    .background(Color(UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)))
                    .padding(.bottom, 21)
                HStack {
                    Text("Password")
                        .font(.system(size: 15.0))
                        .padding(.bottom, 6.0)
                    Spacer()
                }
                .font(.system(size: 15.0))
                .padding(.bottom, 6.0)
                CustomTextFieldView(text: $password, labelText: "Password")
                    .frame(height: 44.0)
                    .background(Color(UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)))
            }
            .padding([.leading, .trailing], 20)
            HStack {
                Spacer()
                NavigationLink(destination: ResetPasswordView()) {
                    Text("Forgot Password?")
                        .foregroundColor(Color(UIColor(red: 60/255, green: 60/255, blue: 67/255, alpha: 0.37)))
                        .font(.system(size: 15.0))
                        .padding(.trailing, 20)
                }
            }
            Spacer()
            VStack {
                Button() {
                    viewModel.signIn(email: emailAddress, password: password)
                } label: {
                    HStack {
                        Spacer()
                        Text("Log in")
                            .foregroundColor(.white)
                            .font(.system(size: 17, weight: .semibold))
                        Spacer()
                    }
                    .contentShape(RoundedRectangle(cornerRadius: 8.0))
                }
                .frame(width: 353, height: 44)
                .buttonStyle(.bordered)
                .background(Color(uiColor: UIColor(named: "mainColor1")!))
                .cornerRadius(8.0)
            }
            Spacer(minLength: 73)
        }
        .navigationTitle("Log in")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if authHandler == nil {
                authHandler = Auth.auth().addStateDidChangeListener({
                    [self]
                    auth, user in
                    Auth.auth().currentUser?.reload()
                    DispatchQueue.main.async() {
                        if user != nil {
                            isLoggedin = false
                        }
                    }
                })
            }
            
        }
    }
    
    func displayError(error: NSError) {
        let e = AuthErrorCode(_nsError: error)
        let code = e.code
        errorString = code.description
        displayError = true
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isLoggedin: .constant(true))
    }
}

