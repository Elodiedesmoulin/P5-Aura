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
    
    private var auraService: AuraService!
    let expectation = XCTestExpectation(description: #function)
    
    override func setUp() {
        super.setUp()
        
        // Configuration de la session URL avec le protocole de test
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)
        
        // Initialisation de `AuraService` avec la session URL simulée
        auraService = AuraService(session: urlSession)
        
    }
    
    override func tearDown() {
        auraService = nil
        super.tearDown()
        MockURLProtocol.loadingHandler = nil
    }
    
    
    func testLogin_successfulResponse() async {
        let jsonString = """
                         {
                            "token": "valid-token"
                         }
                         """
        let data = jsonString.data(using: .utf8)
        
        // Configuration de la réponse et des données pour le mock
        MockURLProtocol.loadingHandler = { request in
            let response = HTTPURLResponse(
                url: URL(string: "\(self.auraService.baseUrl)/auth")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, data)
        }
        
        do {
            let token = try await auraService.login(email: "test@example.com", password: "password")
            XCTAssertEqual(token, "valid-token", "Le token doit être 'valid-token'")
            self.expectation.fulfill()
        } catch {
            XCTFail("Erreur inattendue: \(error)")
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    
    // - MARK: Testing getAccountDetails
    
    func test_getAccountDetails_successfulResponse() async throws {
        // Réponse JSON simulée
        let jsonString = """
            {
                "currentBalance": 1000.0,
                "transactions": [
                    { "value": -50.0, "label": "Grocery" },
                    { "value": 200.0, "label": "Salary" }
                ]
            }
            """
        let data = jsonString.data(using: .utf8)
        
        MockURLProtocol.loadingHandler = { request in
            let response = HTTPURLResponse(
                url: URL(string: "\(self.auraService.baseUrl)/account")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, data)
        }
        
        do {
            let transactionResponse = try await auraService.getAccountDetails(token: "valid-token")
            
            XCTAssertEqual(transactionResponse.currentBalance, 1000.0)
            XCTAssertEqual(transactionResponse.transactions.count, 2)
            XCTAssertEqual(transactionResponse.transactions[0].value, -50.0)
            XCTAssertEqual(transactionResponse.transactions[0].label, "Grocery")
            XCTAssertEqual(transactionResponse.transactions[1].value, 200.0)
            XCTAssertEqual(transactionResponse.transactions[1].label, "Salary")
            
            expectation.fulfill()
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func test_getAccountDetails_invalidResponse() async {
        // Initialisation de l'attente
        let expectation = expectation(description: "Expectation")
        
        // Configuration de la réponse simulée
        MockURLProtocol.loadingHandler = { request in
            let response = HTTPURLResponse(
                url: URL(string: "https://testingurl.com/account")!,
                statusCode: 404, httpVersion: nil, headerFields: [:]
            )!
            return (response, nil)
        }
        
        // Exécution de la fonction testée
        do {
            let token = "invalid-token"
            _ = try await auraService.getAccountDetails(token: token)
            XCTFail("Expected to throw an error due to invalid response")
        } catch AuraServiceError.invalidResponse {
            // Vérification de l'erreur et accomplissement de l'attente
            XCTAssert(true, "Correct error thrown")
            expectation.fulfill()
        } catch {
            XCTFail("Unexpected error: \(error)")
            expectation.fulfill()
        }
        
        // Attente asynchrone de la complétion
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    
    // - MARK: Testing sendMoney
    
    func test_sendMoney_successfulResponse() async {
        // Given
        let expectation = XCTestExpectation(description: "Successful transfer expectation")

        MockURLProtocol.loadingHandler = { request in
            // Simule une réponse de succès avec un code 200
            let response = HTTPURLResponse(
                url: URL(string: "https://testingurl.com/account/transfer")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: [:]
            )!
            return (response, nil) // Réponse avec succès et sans données supplémentaires
        }

        // When
        do {
            let token = "valid-token"
            let recipient = "recipient@example.com"
            let amount: Decimal = 100.0
            try await auraService.sendMoney(token: token, recipient: recipient, amount: amount)
            XCTAssertTrue(true, "Money transfer successful")
            expectation.fulfill() // L'attente est remplie ici lorsque l'appel est effectué avec succès
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
    }

    func test_sendMoney_invalidResponse() async {
        // Given
        let expectation = XCTestExpectation(description: "Invalid response expectation")

        MockURLProtocol.loadingHandler = { request in
            // Simule une réponse serveur avec une erreur HTTP 400 (mauvaise requête)
            let response = HTTPURLResponse(
                url: URL(string: "https://testingurl.com/account/transfer")!,
                statusCode: 400,
                httpVersion: nil,
                headerFields: [:]
            )!
            return (response, nil) // Réponse avec erreur HTTP
        }

        // When
        do {
            let token = "valid-token"
            let recipient = "recipient@example.com"
            let amount: Decimal = 100.0
            _ = try await auraService.sendMoney(token: token, recipient: recipient, amount: amount)
            XCTFail("Expected to throw an error due to invalid response")
        } catch AuraServiceError.invalidResponse {
            // Then
            XCTAssertTrue(true, "Correct error thrown due to invalid response")
            expectation.fulfill()
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
}

