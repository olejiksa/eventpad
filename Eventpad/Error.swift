//
//  Error.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 16.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

extension LocalizedError where Self: CustomStringConvertible {

    var errorDescription: String? {
        return description
    }
}

enum ParserError: Error {
    
    case urlParserError
    case dataParserError
}

struct ResponseError: LocalizedError, CustomStringConvertible {
    
    let statusCode: HttpStatusCode
    
    init(_ statusCode: HttpStatusCode) {
        self.statusCode = statusCode
    }
    
    var description: String {
        return "HTTP Status: \(statusCode.rawValue) (\(statusCode))"
    }
}
