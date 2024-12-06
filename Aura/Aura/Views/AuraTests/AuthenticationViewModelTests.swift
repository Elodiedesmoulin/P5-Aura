//
//  AuthenticationViewModelTests.swift
//  AuraTests
//
//  Created by Elo on 09/11/2024.
//

import XCTest
import Combine
@testable import Aura

class AuthenticationViewModelTests: XCTestCase {
    private var viewModel: AuthenticationViewModel!
    
    let expectation = XCTestExpectation(description: #function)

    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        viewModel = AuthenticationViewModel(session: MockSession()) { token in
            XCTFail("Le callback ne doit pas être appelé ici.")
        }
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Test Validation
    
    func testUsernameValidWithValidEmailShouldReturnTrue() {
        XCTAssertTrue(viewModel.isUsernameValid(username: "test@example.com"))
    }

    func testUsernameValidWithValidPhoneNumberShouldReturnTrue() {
        XCTAssertTrue(viewModel.isUsernameValid(username: "+33612345678"))
    }

    func testUsernameInvalidShouldReturnFalse() {
        XCTAssertFalse(viewModel.isUsernameValid(username: "invalidusername"))
    }

    func testPasswordWithGoodFormatShouldReturnTrue() {
        XCTAssertTrue(viewModel.isPasswordValid(password: "validPassword123"))
    }

    func testPasswordWithTooShortPasswordShouldReturnFalse() {
        XCTAssertFalse(viewModel.isPasswordValid(password: "no"))
    }
    
    // MARK: - Test Login
    
    func testLoginWithInvalidPasswordShouldDisplayErrorMessage() {
        viewModel.username = "test@example.com"
        viewModel.password = "a"
        
        viewModel.$errorMessage
            .dropFirst()
            .sink(receiveValue: { _ in
                self.expectation.fulfill()
            })
            .store(in: &cancellables)
        
        viewModel.login()

        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(viewModel.errorMessage, "Le mot de passe doit avoir au moins 3 caractères.")

    }

    func testLoginWithInvalidUsernameShouldDisplayErrorMessage() {
        viewModel.password = "validPassword123"
        viewModel.username = "invalidusername"
        
        viewModel.$errorMessage
            .dropFirst()
            .sink(receiveValue: { _ in
                self.expectation.fulfill()
            })
            .store(in: &cancellables)
        
        viewModel.login()
        
        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(viewModel.errorMessage, "Le nom d'utilisateur doit être un numéro de téléphone français ou une adresse email valide.")

    }

    func testLoginWithEmptyUsernameShouldDisplayErrorMessage() {
        viewModel.username = ""
        viewModel.password = "validPassword123"
        
        viewModel.$errorMessage
            .dropFirst()
            .sink(receiveValue: { _ in
                self.expectation.fulfill()
            })
            .store(in: &cancellables)
        
        viewModel.login()
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertEqual(viewModel.errorMessage, "Le nom d'utilisateur doit être un numéro de téléphone français ou une adresse email valide.")

    }
    
    func testLoginWithEmptyPassword() {
        viewModel.username = "test@example.com"
        viewModel.password = ""
        
        viewModel.$errorMessage
            .dropFirst()
            .sink(receiveValue: { _ in
                self.expectation.fulfill()
            })
            .store(in: &cancellables)
        
        viewModel.login()
        
        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(viewModel.errorMessage, "Le mot de passe doit avoir au moins 3 caractères.")

    }
    
    // MARK: - Test Success and Failure with Mocked API Response
    
    func testLoginWithValidCredentialsShouldAuthenticateSuccessfully() {

        let session = MockSession(data: FakeResponseData.authCorrectData, error: nil)
        viewModel = AuthenticationViewModel(session: session) { token in
            XCTAssertNotNil(token)
            XCTAssertEqual(token, "mock-token")
        }
        
        viewModel.username = "test@aura.app"
        viewModel.password = "test123"

        viewModel.$isAuthenticated
            .dropFirst()
            .sink(receiveValue: { _ in
               
                self.expectation.fulfill()
            })
            .store(in: &cancellables)
        
        viewModel.login()
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertNil(viewModel.errorMessage)

    }
    
    
    func testLoginWithInvalidCredentialsShouldFailWithErrorMessage() {

        let session = MockSession(data: FakeResponseData.authIncorrectData, urlResponse: FakeResponseData.statusKO, error: FakeResponseData.error)
        viewModel = AuthenticationViewModel(session: session) { token in
            XCTFail("Le callback ne doit pas être appelé en cas d'échec.")
        }
        
        viewModel.username = "test@example.com"
        viewModel.password = "invalidPassword123"
        
        viewModel.$errorMessage
            .dropFirst()
            .sink(receiveValue: { _ in
                self.expectation.fulfill()
            })
            .store(in: &cancellables)
        
        viewModel.login()
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertEqual(viewModel.errorMessage, "A network error occured, please try again.")
        XCTAssertFalse(self.viewModel.isAuthenticated)

    }
    
   
    
    func testLoginWithServerErrorShouldDisplayErrorMessage() {
        let session = MockSession(data: FakeResponseData.authCorrectData, urlResponse: FakeResponseData.statusKO, error: nil)
        viewModel = AuthenticationViewModel(session: session) { token in
            XCTFail("Le callback ne doit pas être appelé en cas d'erreur serveur.")
        }

        viewModel.username = "test@example.com"
        viewModel.password = "test123"

        viewModel.$errorMessage
            .dropFirst()
            .sink(receiveValue: { _ in
                self.expectation.fulfill()
            })
            .store(in: &cancellables)

        viewModel.login()

        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(viewModel.errorMessage, "A network error occurred. Please check your connection and try again.")
        XCTAssertFalse(viewModel.isAuthenticated)
    }
    
}
