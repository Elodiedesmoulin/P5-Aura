//
//  FakeResponseData.swift
//  AuraTests
//
//  Created by Elo on 04/11/2024.
//

import Foundation

class FakeResponseData {
    
    static let responseOK = HTTPURLResponse(
       url: URL(string: "https://testingurl.com")!,
       statusCode: 200, httpVersion: nil, headerFields: [:])!
    
    static let responseKO = HTTPURLResponse(
       url: URL(string: "https://testingurl.com")!,
       statusCode: 500, httpVersion: nil, headerFields: [:])!
}

