//
//  BaseGetRequest.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 16.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

class BaseGetRequest: RequestProtocol {
    
    private let endpoint: String
    private let parameters: [String: Any]
    
    init(endpoint: String, parameters: [String: Any] = [:]) {
        self.endpoint = endpoint
        self.parameters = parameters
    }
    
    var urlRequest: URLRequest? {
        guard
            let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
            let url = URL(string: encodedString)
        else { return nil }
        
        return .init(url: url)
    }
    
    private var urlString: String {
        var formingString = String()
        parameters.forEach { formingString.append("\($0.key)=\($0.value)&") }
        return .init("\(endpoint)?\(formingString.dropLast())")
    }
}
