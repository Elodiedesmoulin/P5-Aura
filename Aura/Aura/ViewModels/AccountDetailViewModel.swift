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
    @Published var allTransactions: [TransactionResponse.Transaction] = []  // Ajout pour stocker toutes les transactions
    let token: String
    
    init(token: String) {
        self.token = token
    }

    func fetchAccountDetails() {
        Task {
            do {
                let accountDetails = try await AuraService().getAccountDetails(token: token)
                DispatchQueue.main.async {
                    self.totalAmount = String(format: "€%.2f", accountDetails.currentBalance)
                    self.recentTransactions = Array(accountDetails.transactions.prefix(3))
                    self.allTransactions = accountDetails.transactions  // Stocke toutes les transactions
                }
            } catch {
                print("Erreur lors de la récupération des détails du compte : \(error.localizedDescription)")
            }
        }
    }
}
