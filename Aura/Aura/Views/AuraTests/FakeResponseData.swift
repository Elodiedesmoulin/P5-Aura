//
//  FakeResponseData.swift
//  AuraTests
//
//  Created by Elo on 04/11/2024.
//

import Foundation

class FakeResponseData {
    
    // MARK: Global
    
    static let statusOK = HTTPURLResponse(
        url: URL(string: "https://openclassrooms.com")!,
        statusCode: 200, httpVersion: nil, headerFields: [:]
    )!
    
    static let statusKO = HTTPURLResponse(
        url: URL(string: "https://openclassrooms.com")!,
        statusCode: 400, httpVersion: nil, headerFields: [:]
    )!
    
    
    // MARK: API Error
    
    // Create class with Error protocol to have instance of Error
    class APIError: Error {}
    static let error = APIError()
    
    // MARK: Incorrect Data
    
    static let authIncorrectData = "erreur".data(using: .utf8)!
    
    // MARK: Correct Data
    
    static var authCorrectData: Data {
        return getData(ofFile: "Authentication")
    }
    
    static var accountDetailCorrectData: Data {
        return getData(ofFile: "AccountDetail")
    }
    
   
}

extension FakeResponseData {
    
    static func getData(ofFile file: String) -> Data {
        let bundle = Bundle(for: FakeResponseData.self)
        
        let url = bundle.url(forResource: file, withExtension: "json")
        
        let data = try! Data(contentsOf: url!)
        return data
    }
}

