//
//  UnderlineTextFieldView.swift
//  FlightPath And NeuroDNA
//
//  Created by Bhavin Patel on 1/30/23.
//

import SwiftUI

struct UnderlineTextFieldView<TextFieldView>: View where TextFieldView: View {
    
    @Binding var text: String
    let textFieldView: TextFieldView
    let placeholder: String
    var imageName: String? = nil
    
    private var isTextFieldWithIcon: Bool {
        return imageName != nil
    }
    
    var body: some View {
        HStack {
            if isTextFieldWithIcon {
                iconImageView
            }
            underlineTextFieldView
        }
    }
}

// MARK: - Setups

extension UnderlineTextFieldView {
    private var iconImageView: some View {
        Image(imageName ?? "")
            .frame(width: 32, height: 32)
            .padding(.leading, 16)
            .padding(.trailing, 16)
    }
    
    private var underlineTextFieldView: some View {
        VStack {
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    placeholderView
                        //.padding(.top, 30)
                }
                
                textFieldView
                    .padding(.trailing, 16)
                    .padding(.leading, isTextFieldWithIcon ? 0 : 16)
                    //.frame(height: 32)
            }
            
            underlineView
        }
    }
    
    private var placeholderView: some View {
        Text(placeholder)
            .foregroundColor(.white)
            .padding(.leading, isTextFieldWithIcon ? 0 : 16)
            .opacity(0.5)
    }
    
    private var underlineView: some View {
        Rectangle().frame(height: 1)
            .foregroundColor(Color(UIColor(red: 60/255, green: 60/255, blue: 67/255, alpha: 0.37)))
            .padding(.trailing, 0)
            .padding(.leading, isTextFieldWithIcon ? 0 : 0)
    }
}

