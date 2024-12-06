//
//  AuraService.swift
//  Aura
//
//  Created by Elo on 22/10/2024.
//

import Foundation


class AuraService {
    
    private let baseUrl = "http://127.0.0.1:8080"
    private let session: SessionProtocol
    
    
    init(session: SessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    
  // MARK: - Private Methods
    
    
    private func createRequest(
        endpoint: String,
        method: String,
        token: String? = nil,
        parameters: [String: Any]? = nil
    ) throws -> URLRequest {
        guard let url = URL(string: "\(baseUrl)\(endpoint)") else {
            throw AuraServiceError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        if let token = token {
            request.setValue(token, forHTTPHeaderField: "token")
        }
        if let parameters = parameters {
            guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
                throw AuraServiceError.invalidTransaction
            }
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
        }
        return request
    }
    
    
    
    private func handleResponse<T: Decodable>(_ data: Data, _ response: URLResponse, decodingType: T.Type) throws -> T {
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw AuraServiceError.networkError
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    
    
    // MARK: - Public Methods

    func login(username: String, password: String) async throws -> String {
        let parameters = ["username": username, "password": password]
        let request = try createRequest(endpoint: "/auth", method: "POST", parameters: parameters)
        let (data, response) = try await session.data(for: request)
        let authResponse: AuthenticationResponse = try handleResponse(data, response, decodingType: AuthenticationResponse.self)
        return authResponse.token
    }
    
    
    
    func getAccountDetails(token: String) async throws -> TransactionResponse {
        let request = try createRequest(endpoint: "/account", method: "GET", token: token)
        let (data, response) = try await session.data(for: request)
        return try handleResponse(data, response, decodingType: TransactionResponse.self)
    }
    
    
    
    func sendMoney(token: String, recipient: String, amount: Decimal) async throws {
        let parameters: [String: Any] = ["recipient": recipient, "amount": amount]
        let request = try createRequest(endpoint: "/account/transfer", method: "POST", token: token, parameters: parameters)
        let (_, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw AuraServiceError.networkError
        }
    }
}

