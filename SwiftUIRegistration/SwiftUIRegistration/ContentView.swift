//
//  ContentView.swift
//  SwiftUIRegistration
//
//  Created by LBX-CL on 2023/3/31.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject private var viewModel = RegistrationViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            VStack {
                RegistrationView(isTextField: true, fieldName: "UserName", fieldValue: $viewModel.username)
                if !viewModel.isUsernameLengthValid {
                    InputErrorView(iconName: "exclamationmark.circle.fill", text: "User Not exist")
                }
            }
            
            VStack {
                RegistrationView(isTextField: false, fieldName: "Password", fieldValue: $viewModel.password)
                if !viewModel.isPasswordLengthValid {
                    InputErrorView(iconName: "exclamationmark.circle.fill", text: "Password error")
                }
            }
            
            VStack {
                RegistrationView(isTextField: false, fieldName: "VerifyPassword", fieldValue: $viewModel.passwordConfirm)
                if !viewModel.isPasswordConfirmValid {
                    InputErrorView(iconName: "exclamationmark.circle.fill", text: "Verify Password is Different")
                }
            }
            
            Button(action: {
                
            }) {
                Text("Register")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.white)
                    .bold()
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(Color(red: 51 / 255, green: 51 / 255, blue: 51 / 255))
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct RegistrationView: View {
    var isTextField = false
    var fieldName = ""
    @Binding var fieldValue: String
    
    var  body: some View {
        if isTextField {
            TextField(fieldName, text: $fieldValue).font(.system(size: 20, weight: .semibold)).padding(.horizontal)
        } else {
            SecureField(fieldName, text: $fieldValue).font(.system(size: 20, weight: .semibold)).padding(.horizontal)
        }
        
        Divider().frame(height: 1).background(Color(red: 240/255, green: 240/255, blue: 240/255)).padding(.horizontal)
    }
}

struct InputErrorView: View {
    var iconName = ""
    var text = ""
    
    var body: some View {
        HStack {
            Image(systemName: iconName).foregroundColor(Color(red: 251/255, green: 128/255, blue: 128/255))
            Text(text).font(.system(.body, design: .rounded)).foregroundColor(Color(red: 251/255, green: 128/255, blue: 128/255))
            Spacer()
        }.padding(.leading, 10)
    }
}

