//
//  MockSession.swift
//  AuraTests
//
//  Created by Elo on 08/11/2024.
//

import Foundation
import XCTest

@testable import Aura

class MockSession: SessionProtocol {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?

    func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        return (mockData ?? Data(), mockResponse ?? HTTPURLResponse())
    }
}
