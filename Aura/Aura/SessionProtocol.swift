//
//  SessionProtocol.swift
//  Aura
//
//  Created by Elo on 04/11/2024.
//

import Foundation

protocol SessionProtocol {
    func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse)
}

extension URLSession: SessionProtocol {
    
}

extension SessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse){
        return try await data(for: request, delegate: nil)
    }
}
