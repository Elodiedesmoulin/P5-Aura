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
    var data: Data?
    var response: URLResponse?
    var error: Error?

    func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }
        return (data ?? Data(), response ?? URLResponse())
    }
}
