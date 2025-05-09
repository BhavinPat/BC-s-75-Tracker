//
//  ResetPasswordView.swift
//  FlightPath And NeuroDNA
//
//  Created by Bhavin Patel on 2/2/23.
//

import SwiftUI
import FirebaseAuth

struct ResetPasswordView: View {
    @State private var emailAddress = ""
    @State private var errorString = ""
    @State private var displayError = false
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {
        VStack() {
            if displayError {
                Text(errorString)
                    .font(.system(size: 15))
                    .padding(.vertical, 30)
            }
            VStack(alignment: .leading) {
                HStack{
                    Text("Your Email")
                    Spacer()
                }
                CustomTextFieldView(text: $emailAddress, labelText: "Email")
                    .frame(height: 44.0)
                    .background(Color(UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)))
                Text("A reset password link will be sent to this email address.")
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                
            }
            Spacer()
            VStack {
                Button() {
                    sendResetPassowrd()
                } label: {
                    HStack {
                        Spacer()
                        Text("Send")
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
        }
        .navigationTitle("Reset password")
        .navigationBarTitleDisplayMode(.large)
        .padding(.horizontal, 12)
        .padding(.bottom, 74)
    }
    func sendResetPassowrd() {
        if !emailAddress.isEmpty {
            if emailAddress.isEmail() {
                Auth.auth().sendPasswordReset(withEmail: emailAddress, completion: {error in
                    if let e = error as? NSError {
                        displayError(error: e)
                    } else {
                        self.presentationMode.wrappedValue.dismiss()
                        displayError = false
                    }
                })
            } else {
                displayError = true
                errorString = "Enter valid email"
            }
        } else {
            displayError = true
            errorString = "Enter email"
        }
    }
    func displayError(error: NSError) {
        let e = AuthErrorCode(_nsError: error)
        let code = e.code
        errorString = code.description
        displayError = true
    }
}

/*
 struct ResetPasswordView_Previews: PreviewProvider {
 static var previews: some View {
 ResetPasswordView()
 }
 }
 */
