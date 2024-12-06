//
//  AccountDetailViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class AccountDetailViewModel: ObservableObject {
    
    @Published var totalAmount: String = "€0.00"
    @Published var recentTransactions: [TransactionResponse.Transaction] = []
    @Published var allTransactions: [TransactionResponse.Transaction] = []
    @Published var errorMessage: String?
    
    let token: String
    var service: AuraService
    
    
    init(token: String, session: SessionProtocol = URLSession.shared) {
        self.token = token
        self.service = AuraService(session: session)
    }
    
    
    
    func fetchAccountDetails() {
        Task {
            do {
                let accountDetails = try await service.getAccountDetails(token: token)
                DispatchQueue.main.async {
                    self.totalAmount = String(format: "€%.2f", accountDetails.currentBalance)
                    self.recentTransactions = Array(accountDetails.transactions.prefix(3))
                    self.allTransactions = accountDetails.transactions
                }
            } catch let error as AuraServiceError {
                DispatchQueue.main.async {
                    self.errorMessage = error.userFriendlyMessage()
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "An unknown error occurred. Please try again later."
                }
            }
        }
    }
}
