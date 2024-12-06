//
//  AuthenticationViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import SwiftUI

class AuthenticationViewModel: ObservableObject {
    
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String? = nil
    
    let onLoginSucceed: ((_ token: String) -> ())
    
    private let session: SessionProtocol
    
    
    
    init(session: SessionProtocol = URLSession.shared, _ callback: @escaping (_ token: String) -> ()) {
        self.session = session
        self.onLoginSucceed = callback
    }
    
    
    
    func login() {
        guard isUsernameValid(username: username) else {
            self.errorMessage = "Le nom d'utilisateur doit être un numéro de téléphone français ou une adresse email valide."
            return
        }
        
        guard isPasswordValid(password: password) else {
            self.errorMessage = "Le mot de passe doit avoir au moins 3 caractères."
            return
        }
        
        Task {
            do {
                let token = try await AuraService(session: session).login(username: username, password: password)
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                    self.errorMessage = nil
                    self.onLoginSucceed(token)
                }
            } catch let error as AuraServiceError {
                DispatchQueue.main.async {
                    self.errorMessage = error.userFriendlyMessage()
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "A network error occured, please try again."
                }
            }
        }
    }
    
    
    func isUsernameValid(username: String) -> Bool {
        let phoneRegex = "^(\\+33|0)[1-9](\\d{8})$" // Format français: +33 ou 0 suivi de 9 chiffres
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$" // Format standard d'email
        
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        return phoneTest.evaluate(with: username) || emailTest.evaluate(with: username)
    }
    
    
    func isPasswordValid(password: String) -> Bool {
        return password.count >= 3
    }
}
