//
//  TransactionResponse.swift
//  Aura
//
//  Created by Elo on 27/10/2024.
//

import Foundation

struct AccountDetailsResponse: Codable {
    let currentBalance: Double
    let transactions: [Transaction]
    
    struct Transaction: Codable, Identifiable {
        let id = UUID()
        let value: Double
        let label: String
    }
}
