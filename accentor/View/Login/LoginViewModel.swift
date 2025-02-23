//
//  LoginViewModel.swift
//  accentor
//
//  Created by Robbe Van Petegem on 05/11/2022.
//

import Foundation
import SwiftUI

class LoginViewModel: ObservableObject {
    enum LoginStates: Equatable {
        case userInput
        case waiting
        case success
        case serverURLIncorrect
        case usernamePasswordIncorrect
    }
    
    @Published var loginState: LoginStates = .userInput
    @Published var serverURL: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    
    private let database: AppDatabase
    
    init(database: AppDatabase) {
        self.database = database
    }

    var errorMessage: String? {
        get {
            switch loginState {
            case .serverURLIncorrect:
                "The server url is not correct"
            case .usernamePasswordIncorrect:
                "Username and password don't match"
            default: nil
            }
        }
    }

    var showAlert: Binding<Bool> {
        Binding(get: { self.errorMessage != nil }, set: { _ in self.loginState = .userInput })
    }
    
    var canSubmit: Bool {
        get {
            !serverURL.isEmpty && !username.isEmpty && !password.isEmpty
        }
    }
    
    func login() async {
        DispatchQueue.main.sync {
            self.loginState = .waiting
        }

        let url = URL(string: serverURL)
        UserDefaults.standard.set(url, forKey: "serverURL")
        
        do {
            try await AuthService(self.database).login(username: username, password: password)

            DispatchQueue.main.async {
                self.loginState = .success
            }
        } catch ApiError.unauthorized {
            DispatchQueue.main.sync {
                self.loginState = .usernamePasswordIncorrect
            }
        } catch {
            DispatchQueue.main.sync {
                self.loginState = .serverURLIncorrect
            }
        }
    }
}
