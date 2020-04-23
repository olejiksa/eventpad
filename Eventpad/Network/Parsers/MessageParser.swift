//
//  MessageParser.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 16.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

final class MessageParser: ParserProtocol {
    
    func parse(data: Data) -> MessageResponse? {
        do {
            let jsonDecorder = JSONDecoder()
            jsonDecorder.dateDecodingStrategy = .iso8601
            jsonDecorder.keyDecodingStrategy = .convertFromSnakeCase
            return try jsonDecorder.decode(MessageResponse.self, from: data)
        } catch  {
            print(error)
            return nil
        }
    }
}
