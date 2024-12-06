//
//  AllTransactionsListView.swift
//  Aura
//
//  Created by Elo on 28/10/2024.
//

import SwiftUI

struct AllTransactionsListView: View {
    var transactions: [TransactionResponse.Transaction]
    
    var body: some View {
        VStack {
            Text("All Transactions")
                .font(.headline)
                .padding()
            
            List(transactions) { transaction in
                HStack {
                    Image(systemName: transaction.value > 0 ? "arrow.up.right.circle.fill" : "arrow.down.left.circle.fill")
                        .foregroundColor(transaction.value > 0 ? .green : .red)
                    Text(transaction.label)
                    Spacer()
                    Text(String(format: "%.2f", transaction.value))
                        .fontWeight(.bold)
                        .foregroundColor(transaction.value > 0 ? .green : .red)
                }
                .padding()
            }
        }
        .navigationTitle("Transactions")
    }
}
