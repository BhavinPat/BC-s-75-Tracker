//
//  ResetPasswordWhenLoggedIn.swift
//  FlightPath And NeuroDNA
//
//  Created by Bhavin Patel on 2/2/23.
//

import SwiftUI
import FirebaseAuth
///There is a bug where navigation (dismiss and push) fail. Causing a huge memory leak. This occcures when a firebase auth signin or createuser completes and the view attempts to dismiss itself.
///There doesnt seem to be a fix that i can identifty. I will be returning to UIKIt for actions that utilize completion functions for Firebase Auth. maybe in the future this code can be put to use. lost 2 days of work :(
struct ResetPasswordWhenLoggedInView: View {
    @State private var emailAddress = ""
    @State private var errorString = ""
    @State private var displayError = false
    var dismissAction: (() -> Void)?
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {
        VStack() {
            if dismissAction == nil {
                HStack {
                    Button() {
                        goBack()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.backward")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .font(.system(size: 17, weight: .bold))
                                .frame(width: 15.66, height: 22.33 )
                                .symbolRenderingMode(.monochrome)
                                .foregroundColor(Color("mainColor1"))
                            Text("Back")
                                .foregroundColor(Color("mainColor1"))
                                .font(.system(size: 17))
                            Spacer()
                        }
                    }
                    Spacer()
                }
            }
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
            //.padding(.horizontal, 17)
            Spacer()
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
            .padding(.bottom, 20)
            
        }
        .padding(.top, 5)
        .navigationTitle("Reset password")
        .navigationBarTitleDisplayMode(.large)
        .padding(.horizontal, 12)
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
    func goBack() {
        dismissAction?()
    }
}

/*
struct ResetPasswordWhenLoggedInView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordWhenLoggedIn()
    }
}
*/

