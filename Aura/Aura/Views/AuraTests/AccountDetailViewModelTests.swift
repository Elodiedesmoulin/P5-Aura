//
//  AccountDetailViewModelTests.swift
//  AuraTests
//
//  Created by Elo on 09/11/2024.
//

import XCTest
import Combine
@testable import Aura

final class AccountDetailViewModelTests: XCTestCase {
    var mockSession: MockSession!
    var viewModel: AccountDetailViewModel!
    
    let expectation = XCTestExpectation(description: #function)

    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockSession = MockSession()
        viewModel = AccountDetailViewModel(token: "mock-token", session: mockSession)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        viewModel = nil
        mockSession = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Tests

    func testFetchAccountDetailsWithValidResponseShouldUpdateViewModel() {
        mockSession.mockData = FakeResponseData.accountDetailCorrectData
        mockSession.mockResponse = FakeResponseData.statusOK
        
        viewModel.$allTransactions
            .dropFirst()
            .sink { _ in
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.fetchAccountDetails()
        
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(viewModel.totalAmount, "€5459.32")
        XCTAssertEqual(viewModel.recentTransactions.count, 3)
        XCTAssertEqual(viewModel.allTransactions.count, 50)
    }

    func testFetchAccountDetailsWithInvalidResponseShouldDisplayErrorMessage() {
        mockSession.mockData = nil
        mockSession.mockResponse = FakeResponseData.statusKO
        mockSession.error = nil
        
        viewModel.$errorMessage
            .dropFirst()
            .sink { _ in
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.fetchAccountDetails()
        
        wait(for: [expectation], timeout: 1)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "A network error occurred. Please check your connection and try again.")
    }
    
    func testFetchAccountDetailsWithIncorrectData() {
        let incorrectData = "{}".data(using: .utf8)
        mockSession.mockData = incorrectData
        
        viewModel.$errorMessage
            .dropFirst()
            .sink { _ in
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.fetchAccountDetails()
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "An unknown error occurred. Please try again later.")
    }
    

    func testFetchAccountDetailsWithError() {
        mockSession.mockResponse = FakeResponseData.statusKO
        
        viewModel.$errorMessage
            .dropFirst()
            .sink { _ in
                self.expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.fetchAccountDetails()
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertEqual(viewModel.errorMessage, "A network error occurred. Please check your connection and try again.")

        XCTAssertEqual(viewModel.totalAmount, "€0.00")
        XCTAssertTrue(viewModel.recentTransactions.isEmpty)
        XCTAssertTrue(viewModel.allTransactions.isEmpty)
    }
}
