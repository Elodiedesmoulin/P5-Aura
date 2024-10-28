//
//  AuraServiceError.swift
//  Aura
//
//  Created by Elo on 28/10/2024.
//

import Foundation

enum AuraServiceError: LocalizedError {
    case invalidUrl
    case invalidParameters
    case invalidAuthentication
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidUrl:
            return "URL invalide."
        case .invalidParameters:
            return "Paramètres de requête incorrects."
        case .invalidAuthentication:
            return "Authentification échouée, token non trouvé ou incorrect."
        case .invalidResponse:
            return "Réponse du serveur non valide."
        }
    }
}
