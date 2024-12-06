//
//  MoneyTransferViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class MoneyTransferViewModel: ObservableObject {
    
    @Published var recipient: String = ""
    @Published var amount: String = ""
    @Published var transferMessage: String = ""
    @Published var currentBalance: Double = 0.0
    
    var service = AuraService()
    let token: String

    
    init(token: String, session: SessionProtocol = URLSession.shared) {
        self.token = token
        self.service = AuraService(session: session)
        fetchCurrentBalance()
    }

    
    // MARK: - Private Method
    
    private func isValidRecipient(_ recipient: String) -> Bool {
        let phoneRegex = "^(\\+33|0)[1-9](\\d{8})$"
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"

        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)

        return phoneTest.evaluate(with: recipient) || emailTest.evaluate(with: recipient)
    }
    
    
    // MARK: - Public Methods

    
    func fetchCurrentBalance() {
        Task {
            do {
                let accountDetails = try await service.getAccountDetails(token: token)
                DispatchQueue.main.async {
                    self.currentBalance = accountDetails.currentBalance
                }
            } catch {
                DispatchQueue.main.async {
                    self.transferMessage = "Please enter a valid French email address or phone number."
                }
            }
        }
    }

    
    func sendMoney() {
        guard isValidRecipient(recipient) else {
            self.transferMessage = "Please enter a valid French email address or phone number."
            return
        }

        guard let amountDecimal = Decimal(string: amount),
              let amountDouble = Double(amountDecimal.description),
              amountDecimal > 0,
              amountDecimal <= 10000 else {
            self.transferMessage = "Please enter an amount between 0 and 10,000 €."
            return
        }

        guard amountDouble <= currentBalance else {
            self.transferMessage = "The amount exceeds your available balance of \(String(format: "%.2f", currentBalance)) €."
            return
        }

        Task {
            do {
                try await service.sendMoney(token: token, recipient: recipient, amount: Decimal(amountDouble))
                DispatchQueue.main.async {
                    self.currentBalance -= amountDouble  // Mise à jour locale du solde
                    self.transferMessage = "The transfer of \(String(format: "%.2f", amountDouble)) € to \(self.recipient) has been successfully completed."
                    self.recipient = ""
                    self.amount = ""
                }
            } catch let error as AuraServiceError {
                DispatchQueue.main.async {
                    self.transferMessage = error.userFriendlyMessage()
                }
            } catch {
                DispatchQueue.main.async {
                    self.transferMessage = "An unknown error has occured. Please try again."
                }
            }
        }
    }
}
