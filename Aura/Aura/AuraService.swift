//
//  AuraService.swift
//  Aura
//
//  Created by Elo on 22/10/2024.
//

import Foundation

class AuraService {
    
    let baseUrl = "http://127.0.0.1:8080"
    
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
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw AuraServiceError.invalidAuthentication
        }
        
        let authenticationResponse = try JSONDecoder().decode(AuthenticationResponse.self, from: data)
        return authenticationResponse.token
    }
    
    func getAccountDetails(token: String) async throws -> AccountDetailsResponse {
        
        guard let url = URL(string: "\(baseUrl)/account") else {
            throw AuraServiceError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "token")
        
        print("Request URL:", request.url?.absoluteString ?? "No URL")
        print("Request Headers:", request.allHTTPHeaderFields ?? "No Headers")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Status Code:", httpResponse.statusCode)
            if httpResponse.statusCode != 200 {
                throw AuraServiceError.invalidResponse
            }
        }
        
        print("Response Data:", String(data: data, encoding: .utf8) ?? "No data")
        
        let accountDetails = try JSONDecoder().decode(AccountDetailsResponse.self, from: data)
        return accountDetails
    }
}

