//
//  AuraServiceTest.swift
//  AuraTests
//
//  Created by Elo on 09/11/2024.
//

import XCTest
@testable import Aura

// MARK: - AuraServiceTest

final class AuraServiceTest: XCTestCase {
    
    let expectation = XCTestExpectation(description: #function)
    
    
    func testLoginWithValidCredentialsShouldReturnToken() async {
        let mockSession = MockSession(data: FakeResponseData.authCorrectData, urlResponse: FakeResponseData.statusOK)
        let auraService = AuraService(session: mockSession)
        
        do {
            let token = try await auraService.login(username: "test", password: "password")
            
            XCTAssertEqual(token, "mock-token")
        } catch {
            XCTFail("L'authentification a échoué avec l'erreur: \(error)")
        }
    }
    
    
    func testLoginWithInvalidCredentialsShouldFailWithNetworkError() async {
        
        let mockSession = MockSession(data: FakeResponseData.authIncorrectData, urlResponse: FakeResponseData.statusKO)
        let auraService = AuraService(session: mockSession)
        
        do {
            _ = try await auraService.login(username: "test@aura.app", password: "test123")
            XCTFail("Authentication should fail")
        } catch {
            XCTAssertEqual(error as? AuraServiceError, .networkError)
        }
    }
    
    
    
    // MARK: - Testing getAccountDetails
    
    
    func testGetAccountDetailsWithValidResponseShouldReturnTransactionData() async throws {
        let mockSession = MockSession(data: FakeResponseData.accountDetailCorrectData,
                                      urlResponse: FakeResponseData.statusOK)
        let auraService = AuraService(session: mockSession)
        
        do {
            let transactionResponse = try await auraService.getAccountDetails(token: "mock-token")
            
            XCTAssertEqual(transactionResponse.currentBalance, 5459.32)
            XCTAssertEqual(transactionResponse.transactions.count, 50)
            XCTAssertEqual(transactionResponse.transactions[0].value, -56.4)
            XCTAssertEqual(transactionResponse.transactions[0].label, "IKEA")
            XCTAssertEqual(transactionResponse.transactions[1].value, -10)
            XCTAssertEqual(transactionResponse.transactions[1].label, "Starbucks")
            XCTAssertEqual(transactionResponse.transactions[2].value, 1400)
            XCTAssertEqual(transactionResponse.transactions[2].label, "Pole Emploi")
            
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    
    func testGetAccountDetailsWithInvalidResponseShouldFailWithNetworkError() async throws {
        let mockSession = MockSession(data: FakeResponseData.accountDetailCorrectData,
                                      urlResponse: FakeResponseData.statusKO)
        let auraService = AuraService(session: mockSession)
        
        do {
            _ = try await auraService.getAccountDetails(token: "mock-token")
            XCTFail("Expected error, but got a valid response")
        } catch {
            XCTAssertEqual(error as? AuraServiceError, .networkError)
        }
    }
    
    
    // MARK: - Testing sendMoney
    
    
    func testSendMoneyWithValidResponseShouldSucceed() async throws {
        let mockSession = MockSession(data: FakeResponseData.accountDetailCorrectData,
                                      urlResponse: FakeResponseData.statusOK,
                                      error: nil)
        let auraService = AuraService(session: mockSession)
        
        let token = "mock-token"
        let recipient = "recipient@example.com"
        let amount: Decimal = 100.0
        try await auraService.sendMoney(token: token, recipient: recipient, amount: amount)
        
    }
    
    
    func testSendMoneyWithInvalidResponseShouldFailWithNetworkError() async {
        let mockSession = MockSession(data: FakeResponseData.accountDetailCorrectData,
                                      urlResponse: FakeResponseData.statusKO,
                                      error: nil)
        let auraService = AuraService(session: mockSession)
        
        do {
            let token = "mock-token"
            let recipient = "recipient@example.com"
            let amount: Decimal = 100.0
            
            try await auraService.sendMoney(token: token, recipient: recipient, amount: amount)
            
            XCTFail("Expected to throw an error due to invalid response")
        } catch {
            XCTAssertEqual(error as? AuraServiceError, .networkError)
        }
    }
}

