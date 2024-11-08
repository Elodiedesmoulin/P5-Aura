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
    private var service = AuraService()
    
    let token: String
    
    init(token: String) {
        self.token = token
    }
    
    func sendMoney() {
        guard isValidRecipient(recipient) else {
                self.transferMessage = "Veuillez entrer une adresse e-mail ou un numéro de téléphone français valide."
            return
        }
        
        guard let amountDecimal = Decimal(string: amount), amountDecimal > 0 else {
                self.transferMessage = "Veuillez entrer un montant valide."
            return
        }
        Task{
            do {
                try await service.sendMoney(token: token, recipient: recipient, amount: amountDecimal)
                DispatchQueue.main.async {
                    self.transferMessage = "Le transfert de \(self.amount) € vers \(self.recipient) a été effectué avec succès."
                    self.recipient = ""
                    self.amount = ""
                }
            } catch {
                DispatchQueue.main.async {
                    self.transferMessage = "Échec du transfert : \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func isValidRecipient(_ recipient: String) -> Bool {
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", "^[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,64}$")
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", "^\\+33[1-9][0-9]{8}$")
        return emailPredicate.evaluate(with: recipient) || phonePredicate.evaluate(with: recipient)
    }
}
