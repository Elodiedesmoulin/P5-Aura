//
//  AppViewModel.swift
//  Aura
//
//  Created by Elo on 28/10/2024.
//

import Foundation

class AppViewModel: ObservableObject {
    @Published var isLogged: Bool
    var token: String?
    let session: SessionProtocol
    
    init(session: SessionProtocol = URLSession.shared) {
        isLogged = false
        self.session = session
    }
    
    var authenticationViewModel: AuthenticationViewModel {
        return AuthenticationViewModel(session: session) { [weak self] token in
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
