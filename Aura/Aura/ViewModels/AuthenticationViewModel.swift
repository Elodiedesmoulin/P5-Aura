//
//  AuthenticationViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import SwiftUI


class AuthenticationViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String? = nil
    
    let onLoginSucceed: (() -> ())
    
    init(_ callback: @escaping () -> ()) {
        self.onLoginSucceed = callback
    }
    
    func login() {
        guard isPasswordValid() else {
            self.errorMessage = "Le mot de passe doit avoir au moins 3 caractères."
            return
        }
        
        Task {
            do {
                let token = try await AuraService().login(email: email, password: password)
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                    self.onLoginSucceed()
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    print(self.errorMessage)
                }
            }
        }
        
    }
    
    func isPasswordValid() -> Bool {
        return password.count >= 3
    }
}
