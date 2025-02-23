//
//  Login.swift
//  accentor
//
//  Created by Robbe Van Petegem on 05/11/2022.
//

import SwiftUI
import GRDBQuery

struct LoginView: View {
    @EnvironmentStateObject private var viewModel: LoginViewModel

    init() {
        _viewModel = EnvironmentStateObject {
            LoginViewModel(database: $0.appDatabase)
        }
    }
    
    var body: some View {
        ZStack {
            Form {
                Section(header: Text("Sign in to accentor")) {
                    TextField("Server URL", text: $viewModel.serverURL)
#if os(iOS)
                        .textInputAutocapitalization(.never)
#endif
                        .disableAutocorrection(true)
                    TextField("Username", text: $viewModel.username)
#if os(iOS)
                        .textInputAutocapitalization(.never)
#endif
                    SecureField("Password", text: $viewModel.password)
                }
                Section {
                    Button(action: { Task { await viewModel.login() }}) {
                        Text("Sign in")
                    }.disabled(!viewModel.canSubmit)
                }
            }.alert(isPresented: viewModel.showAlert) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage!), dismissButton: .default(Text("OK")))
            }.disabled(viewModel.loginState == .waiting)
            
            if viewModel.loginState == .waiting {
                ProgressView()
            }
        }
        
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
