//
//  RequestConfig.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 16.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

protocol RequestProtocol {
    var urlRequest: URLRequest? { get }
}

protocol ParserProtocol {
    associatedtype Model
    func parse(data: Data) -> Model?
}

struct RequestConfig<Parser> where Parser: ParserProtocol {
    let request: RequestProtocol
    let parser: Parser
    
    init(request: RequestProtocol, parser: Parser) {
        self.request = request
        self.parser = parser
    }
}
