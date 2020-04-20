//
//  LoginParser.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 16.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

final class LoginParser: ParserProtocol {
    
    func parse(data: Data) -> Login? {
        do {
            let jsonDecorder = JSONDecoder()
            jsonDecorder.dateDecodingStrategy = .iso8601
            jsonDecorder.keyDecodingStrategy = .convertFromSnakeCase
            return try jsonDecorder.decode(Login.self, from: data)
        } catch  {
            print(error)
            return nil
        }
    }
}
