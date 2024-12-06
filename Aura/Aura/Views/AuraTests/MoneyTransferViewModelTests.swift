//
//  MoneyTransferViewModelTests.swift
//  AuraTests
//
//  Created by Elo on 09/11/2024.
//
//

import XCTest
import Combine
@testable import Aura

final class MoneyTransferViewModelTests: XCTestCase {
    var mockSession: MockSession!
    var viewModel: MoneyTransferViewModel!
    
    let expectation = XCTestExpectation(description: #function)
    
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockSession = MockSession()
        viewModel = MoneyTransferViewModel(token: "mock-token", session: mockSession)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        viewModel = nil
        mockSession = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testSendMoneyWithInvalidRecipientShouldDisplayErrorMessage() {
        viewModel.recipient = "invalidRecipient"
        viewModel.amount = "10"
        
        viewModel.sendMoney()
        
        XCTAssertEqual(viewModel.transferMessage, "Please enter a valid French email address or phone number.")
    }
    
    
    func testSendMoneyWithInvalidAmountShouldDisplayErrorMessage() {
        viewModel.recipient = "test@example.com"
        viewModel.amount = "-10"
        
        viewModel.sendMoney()
        
        XCTAssertEqual(
            viewModel.transferMessage,
            "Please enter an amount between 0 and 10,000 €."
        )
    }
    
    func testSendMoneyExceedingBalanceShouldDisplayErrorMessage() {
        viewModel.recipient = "test@example.com"
        viewModel.amount = "6000.0"
        viewModel.currentBalance = 5459.32
        
        viewModel.sendMoney()
        
        XCTAssertEqual(
            viewModel.transferMessage,
            "The amount exceeds your available balance of 5459.32 €."
        )
    }
    
    func testFetchCurrentBalanceShouldUpdateBalance() async {
        mockSession.mockData = FakeResponseData.accountDetailCorrectData
        
        viewModel.$currentBalance
            .dropFirst()
            .sink { _ in
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.fetchCurrentBalance()
        
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(viewModel.currentBalance, 5459.32)
    }
    
    func testSendMoneyWithValidRecipientAndAmountShouldPublishSuccessMessage() async {
        mockSession.mockData = FakeResponseData.accountDetailCorrectData
        viewModel.recipient = "test@example.com"
        viewModel.amount = "10.0"
        viewModel.currentBalance = 5459.32
        
        viewModel.$transferMessage
            .dropFirst()
            .sink(receiveValue: { _ in
                self.expectation.fulfill()
            })
            .store(in: &cancellables)
        
        viewModel.sendMoney()
        
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(viewModel.transferMessage, "The transfer of 10.00 € to test@example.com has been successfully completed.")
        XCTAssertEqual(viewModel.recipient, "")
        XCTAssertEqual(viewModel.amount, "")
    }
    
    
    func testSendMoneyWithInvalidServerResponseShouldPublishFailureMessage() async {
        mockSession.mockResponse = FakeResponseData.statusKO
        viewModel.recipient = "test@example.com"
        viewModel.amount = "10"
        viewModel.currentBalance = 5459.32
        
        viewModel.$transferMessage
            .dropFirst()
            .sink { _ in
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.sendMoney()
        
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(viewModel.transferMessage, "A network error occurred. Please check your connection and try again.")
        
    }
}
