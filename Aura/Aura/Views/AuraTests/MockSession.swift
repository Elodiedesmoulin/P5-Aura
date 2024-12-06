//
//  MockSession.swift
//  AuraTests
//
//  Created by Elo on 08/11/2024.
//

import Foundation
import XCTest

@testable import Aura

final class MockSession: SessionProtocol {
    var mockData: Data?
    var mockResponse: URLResponse?
    var error: Error?
    
    init(data: Data? = nil, urlResponse: URLResponse? = FakeResponseData.statusOK, error: Error? = nil) {
        self.mockData = data
        self.mockResponse = urlResponse
        self.error = error
    }
    
    func data(for request: URLRequest, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }
        
        if let response = mockResponse as? HTTPURLResponse {
            if response.statusCode == 400 {
                throw AuraServiceError.networkError
            }
        }
        
        guard let data = mockData, let urlResponse = mockResponse else {
            throw URLError(.badServerResponse)
        }
        return (data, urlResponse)
    }
}


