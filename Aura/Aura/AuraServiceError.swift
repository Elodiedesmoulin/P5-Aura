//
//  AuraServiceError.swift
//  Aura
//
//  Created by Elo on 28/10/2024.
//

import Foundation

enum AuraServiceError: LocalizedError {
    case invalidUrl
    case networkError
    case invalidCredentials
    case insufficientFunds
    case invalidTransaction
    
    var errorDescription: String? {
        switch self {
        case .invalidUrl:
            return "The URL is nt valid."
        case .networkError:
            return "A network error occurred. Please check your connection and try again."
        case .invalidCredentials:
            return "The credentials provided are incorrect. Please try again."
        case .insufficientFunds:
            return "You do not have enough funds to complete this transaction."
        case .invalidTransaction:
            return "The amount or recipient provided is incorrect. Please try again."
        }
    }
}


extension Error {
    func userFriendlyMessage() -> String {
        if let error = self as? AuraServiceError {
            return error.localizedDescription
        }
        return "An unknown error occurred. Please try again later."
    }
}
