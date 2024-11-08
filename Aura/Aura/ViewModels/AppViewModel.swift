//
//  AppViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class AppViewModel: ObservableObject {
    @Published var isLogged: Bool
    var token: String?
    
    init() {
        isLogged = false
    }
    
    var authenticationViewModel: AuthenticationViewModel {
        return AuthenticationViewModel { [weak self] token in
            self?.token = token
            self?.isLogged = true
        }
    }
    
    var accountDetailViewModel: AccountDetailViewModel {
        return AccountDetailViewModel(token: token!)
    }
    
    var moneyTransferViewModel: MoneyTransferViewModel {
        return MoneyTransferViewModel(token: token!)
    }
}
