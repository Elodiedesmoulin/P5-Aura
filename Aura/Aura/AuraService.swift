//
//  AuraService.swift
//  Aura
//
//  Created by Elo on 22/10/2024.
//

import Foundation

class AuraService {
    
    let baseUrl = "http://127.0.0.1:8080"
    let session: SessionProtocol
    
    init(session: SessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func login(username: String, password: String) async throws -> String {
        
        guard let url = URL(string: "\(baseUrl)/auth") else {
            throw AuraServiceError.invalidUrl
        }
        
        let parameters = [
            "username": username,
            "password": password
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
            throw AuraServiceError.invalidCredentials
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw AuraServiceError.networkError
        }
        
        let authenticationResponse = try JSONDecoder().decode(AuthenticationResponse.self, from: data)
        return authenticationResponse.token
    }

    
    func getAccountDetails(token: String) async throws -> TransactionResponse {
        
        guard let url = URL(string: "\(baseUrl)/account") else {
            throw AuraServiceError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "token")
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode != 200 {
                throw AuraServiceError.networkError
            }
        }
        
        let accountDetails = try JSONDecoder().decode(TransactionResponse.self, from: data)
        return accountDetails
    }
    
    func sendMoney(token: String, recipient: String, amount: Decimal) async throws {
        guard let url = URL(string: "\(baseUrl)/account/transfer") else {
            throw AuraServiceError.invalidUrl
        }
        
        let parameters: [String: Any] = [
            "recipient": recipient,
            "amount": amount
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
            throw AuraServiceError.invalidTransaction
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "token")
        request.httpBody = jsonData
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw AuraServiceError.networkError
        }
    }
}

