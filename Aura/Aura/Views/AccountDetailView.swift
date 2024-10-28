//
//  AccountDetailView.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import SwiftUI

struct AccountDetailView: View {
    @ObservedObject var viewModel: AccountDetailViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            
            VStack(spacing: 10) {
                Text("Your Balance")
                    .font(.headline)
                Text(viewModel.totalAmount)
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(Color(hex: "#94A684"))
                Image(systemName: "eurosign.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                    .foregroundColor(Color(hex: "#94A684"))
            }
            .padding(.top)
            
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Recent Transactions")
                    .font(.headline)
                    .padding([.horizontal])
                
                
                ForEach(viewModel.recentTransactions) { transaction in
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
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding([.horizontal])
                }
            }
            
            
            Button(action: {
                
                print("See all transactions action triggered.")
            }) {
                HStack {
                    Image(systemName: "list.bullet")
                    Text("See Transaction Details")
                }
                .padding()
                .background(Color(hex: "#94A684"))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding([.horizontal, .bottom])
            
            Spacer()
        }
        .onAppear {
            Task {
                await viewModel.fetchAccountDetails()
            }
        }
        .onTapGesture {
            self.endEditing(true)
        }
    }
}

//#Preview {
//    AccountDetailView(viewModel: AccountDetailViewModel())
//}
