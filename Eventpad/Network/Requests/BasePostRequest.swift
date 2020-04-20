//
//  BasePostRequest.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 16.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

class BasePostRequest: RequestProtocol {
    
    private let endpoint: String
    private let parameters: [String: Any]
    
    init(endpoint: String, parameters: [String: Any] = [:]) {
        self.endpoint = endpoint
        self.parameters = parameters
    }
    
    open var urlRequest: URLRequest? {
        guard
            let encodedString = endpoint.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
            let url = URL(string: encodedString)
        else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
        request.httpBody = jsonData
        
        return request
    }
}
