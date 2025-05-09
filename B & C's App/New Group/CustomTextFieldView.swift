//
//  CustomTextFieldView.swift
//  FlightPath And NeuroDNA
//
//  Created by Bhavin Patel on 1/30/23.
//

import SwiftUI

struct CustomTextFieldView: View {
    @Binding var text: String
    var labelText = ""
    @State private var islabelHidden = false
    var body: some View {
        HStack(alignment: .center) {
            if labelText == "Password" || labelText == "Confirm Password" {
                UnderlineTextFieldView(text: $text, textFieldView: passwordView, placeholder: labelText)
                    .onTapGesture {
                        islabelHidden = true
                    }
                    .onSubmit {
                        islabelHidden = false
                    }
                    .textFieldStyle(.plain)
                    .padding(.top, 10)
            } else {
                UnderlineTextFieldView(text: $text, textFieldView: textView, placeholder: labelText)
                    .onTapGesture {
                        islabelHidden = true
                    }
                    .onSubmit {
                        islabelHidden = false
                    }
                    .textFieldStyle(.plain)
                    .padding(.top, 10)
            }
        }
    }
}
extension CustomTextFieldView {
    private var textView: some View {
        TextField("", text: $text)
            .placeholder(when: text.isEmpty) {
                Text(labelText).foregroundColor(Color(UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)))
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
    }
    
    private var passwordView: some View {
        SecureField("", text: $text)
            .placeholder(when: text.isEmpty) {
                Text(labelText).foregroundColor(Color(UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)))
                    .autocapitalization(.none)
            }
    }
    
}
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
/*
 struct CustomTextFieldView_Previews: PreviewProvider {
 static var previews: some View {
 CustomTextFieldView()
 }
 }
 */
