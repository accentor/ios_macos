//
//  Login.swift
//  accentor
//
//  Created by Robbe Van Petegem on 05/11/2022.
//

import SwiftUI

struct Login: View {
    @State var serverURL: String = ""
    @State var username: String = ""
    @State var password: String = ""
    @StateObject var viewModel = LoginViewModel()

    var body: some View {
        VStack {
            Text("Log in to accentor").font(.largeTitle).fontWeight(.semibold).padding(.bottom, 20)
            TextField("Server URL", text: $serverURL).padding()
                #if os(iOS)
                .textInputAutocapitalization(.never)
                #endif
                .disableAutocorrection(true)
                .overlay(
                    RoundedRectangle(cornerRadius: 10.0)
                        .stroke(lineWidth: 2.0)
                )
                .padding(.bottom, 20)
            TextField("Username", text: $username).padding()
                #if os(iOS)
                .textInputAutocapitalization(.never)
                #endif
                .disableAutocorrection(true)
                .overlay(
                    RoundedRectangle(cornerRadius: 10.0)
                        .stroke(lineWidth: 2.0)
                )
                .padding(.bottom, 20)
            SecureField("Password", text: $password).padding()
                .border(.secondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 10.0)
                        .stroke(lineWidth: 2.0)
                )
                .padding(.bottom, 20)
            
            switch viewModel.loginState {
            case .success: Text("Login succeeded!").font(.headline).foregroundColor(.green)
            case .serverURLIncorrect: Text("Not a valid server url").foregroundColor(.red)
            case .usernamePasswordIncorrect: Text("Username and password were not correct. Try again.").foregroundColor(.red)
            case .waiting: Text("")
            }
            
            Button(action: { viewModel.login(serverURL: serverURL, username: username, password: password) }) {
                Text("Login").font(.title3).padding(15.0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10.0)
                            .stroke(lineWidth: 2.0)
                    )
            }
            
        }.padding(20)
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
    }
}
