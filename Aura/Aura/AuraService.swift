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
    
    func login(email: String, password: String) async throws -> String {
        
        guard let url = URL(string: "\(baseUrl)/auth") else {
            throw AuraServiceError.invalidUrl
        }
        
        let parameters = [
            "username": email,
            "password": password
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
            throw AuraServiceError.invalidParameters
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw AuraServiceError.invalidAuthentication
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
        
        print("Request URL:", request.url?.absoluteString ?? "No URL")
        print("Request Headers:", request.allHTTPHeaderFields ?? "No Headers")
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Status Code:", httpResponse.statusCode)
            if httpResponse.statusCode != 200 {
                throw AuraServiceError.invalidResponse
            }
        }
        
        print("Response Data:", String(data: data, encoding: .utf8) ?? "No data")
        
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
            throw AuraServiceError.invalidParameters
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "token")
        request.httpBody = jsonData
        
        print("Headers:", request.allHTTPHeaderFields ?? "No Headers")
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw AuraServiceError.invalidResponse
        }
        
        print("Transfert réussi:", String(data: data, encoding: .utf8) ?? "Aucune donnée")
    }
    
    
}

