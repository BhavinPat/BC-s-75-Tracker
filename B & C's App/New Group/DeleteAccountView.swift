//
//  DeleteAccountView.swift
//  FlightPath And NeuroDNA
//
//  Created by Bhavin Patel on 2/2/23.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
///There is a bug where navigation (dismiss and push) fail. Causing a huge memory leak. This occcures when a firebase auth signin or createuser completes and the view attempts to dismiss itself.
///There doesnt seem to be a fix that i can identifty. I will be returning to UIKIt for actions that utilize completion functions for Firebase Auth. maybe in the future this code can be put to use. lost 2 days of work :(
struct DeleteAccountView: View {
    @State private var password = ""
    @State private var errorString = ""
    @State private var displayError = false
    var dismissAction: (() -> Void)
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {
        VStack() {
            HStack {
                Button() {
                    goBack()
                } label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 15.66, height: 22.33 )
                            .font(.system(size: 17, weight: .bold))
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
            HStack {
                Text("Delete Account")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.bottom, 40)
                    .padding(.leading, 20)
                Spacer()
            }
            .padding(.bottom, 20)
            if displayError {
                Text(errorString)
                    .font(.system(.caption))
                    .padding(.bottom, 40)
            }
            VStack {
                HStack{
                    Text("Enter the password associated with the email: \(Auth.auth().currentUser!.email!). When you delete your account all data collected will also be deleted. This action can't be undone.")
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                    Spacer()
                }
                CustomTextFieldView(text: $password, labelText: "Password")
                    .frame(height: 44.0)
                    .background(Color(UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)))
                //Text("A reset password link will be sent to this email address.")
                    
            }
            .padding(.horizontal, 5)
            Spacer()
            VStack {
                Button() {
                    deleteAccount()
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
            Spacer(minLength: 73)
        }
        .padding(.top, 5)
        .padding(.horizontal, 12)
    }
    func deleteAccount() {
        let storage = Storage.storage()
        if !password.isEmpty {
            Auth.auth().signIn(withEmail: (Auth.auth().currentUser?.email!)!, password: password, completion: {
                userResults, error in
                if let e = error as? NSError {
                    displayError(error: e)
                } else if Auth.auth().currentUser! == userResults?.user {
                    if let user = Auth.auth().currentUser {
                        let ref = storage.reference().child("/user/\(user.uid)/")
                        ref.listAll(completion: { [self]
                            results, error in
                            if let e = error as? NSError {
                                displayStorageError(error: e)
                            } else {
                                if let results = results {
                                    results.items.forEach({
                                        value in
                                        value.delete(completion: { error in
                                            if error == nil {
                                                Auth.auth().currentUser?.delete(completion: {
                                                    [self] error in
                                                    if let e = error as? NSError {
                                                        self.displayError(error: e)
                                                    } else {
                                                        displayError = false
                                                        self.presentationMode.wrappedValue.dismiss()
                                                        //BTINF TO SPLACH LOGIN VIEWFBOGURBUR
                                                    }
                                                })
                                            } else {
                                                displayError = true
                                                errorString = "Error deleting account. Please try again later."
                                            }
                                        })
                                    })
                                }
                            }
                        })
                    }
                } else {
                    displayError = true
                    errorString = "Error deleting account. Please try again later"
                }
            })
        } else {
            displayError = true
            errorString = "Enter password"
        }
    }
    func goBack() {
        dismissAction()
    }
    func displayStorageError(error: NSError) {
        let e = StorageErrorCode(rawValue: error.code)!
        errorString = e.description
        displayError = true
    }
    func displayError(error: NSError) {
        let e = AuthErrorCode(_nsError: error)
        let code = e.code
        errorString = code.description
        displayError = true
    }
}
/*
struct DeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteAccountView()
    }
}
*/
