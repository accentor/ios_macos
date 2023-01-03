//
//  LoginViewModel.swift
//  accentor
//
//  Created by Robbe Van Petegem on 05/11/2022.
//

import Foundation
import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var loginState: LoginStates = .waiting
    
    func login(serverURL: String, username: String, password: String) {
        print("Loggin in with \(serverURL), \(username), \(password) ")
        // Reset state
        self.loginState = .waiting
        let url = URL(string: serverURL)
        UserDefaults.standard.set(url, forKey: "serverURL")
        
        AuthService.shared.login(username: username, password: password, completion: {(response, error) in
            guard let response = response, error == nil else {
                DispatchQueue.main.async {
                    self.loginState = .usernamePasswordIncorrect
                }
                return
            }
            
            UserDefaults.standard.set(response.deviceId, forKey: "deviceId")
            UserDefaults.standard.set(response.secret, forKey: "secret")
            UserDefaults.standard.set(response.userId, forKey: "userId")
            DispatchQueue.main.async {
                self.loginState = .success
            }
        })
    }
}

enum LoginStates: Equatable {
    case waiting
    case success
    case serverURLIncorrect
    case usernamePasswordIncorrect
}
