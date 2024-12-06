//
//  AppViewModelTests.swift
//  AuraTests
//
//  Created by Elo on 10/11/2024.
//

import XCTest
import Combine
@testable import Aura

final class AppViewModelTests: XCTestCase {
    
    var appViewModel: AppViewModel!
    var mockSession: MockSession!
    
    private var cancellables: Set<AnyCancellable>!
    
    
    override func setUp() {
        super.setUp()
        
        mockSession = MockSession(data: nil, urlResponse: nil, error: nil)
        appViewModel = AppViewModel(session: mockSession)
        
        cancellables = []
        
    }
    
    
    
    func testAuthenticationSuccessSetsTokenAndIsLogged() {
        
        let authViewModel = appViewModel.authenticationViewModel
        let expectation = XCTestExpectation(description: #function)
        
        mockSession.mockData = try! JSONEncoder().encode(AuthenticationResponse(token: "mock-token"))
        mockSession.mockResponse = FakeResponseData.statusOK
        
        authViewModel.username = "test@aura.app"
        authViewModel.password = "test123"
        
        appViewModel.$isLogged
            .dropFirst()
            .sink(receiveValue: { _ in
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        authViewModel.login()
        wait(for: [expectation], timeout: 1)
        
        XCTAssertTrue(appViewModel.isLogged)
        XCTAssertEqual(appViewModel.token, "mock-token")
    }
    
    
    func testAccountDetailViewModelUsesTokenAfterLogin() async {
        
        appViewModel.token = "mockToken"
        
        let accountDetailViewModel = appViewModel.accountDetailViewModel
        
        XCTAssertEqual(accountDetailViewModel.token, appViewModel.token)
    }
    
    
    func testMoneyTransferViewModelUsesTokenAfterLogin() async {
        
        appViewModel.token = "mockToken"
        
        let moneyTransferViewModel = appViewModel.moneyTransferViewModel
        
        XCTAssertEqual(moneyTransferViewModel.token, "mockToken")
    }
}
