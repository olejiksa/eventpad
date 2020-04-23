//
//  TicketParser.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 23.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

final class TicketParser: ParserProtocol {
    
    func parse(data: Data) -> Ticket? {
        do {
            let jsonDecorder = JSONDecoder()
            jsonDecorder.dateDecodingStrategy = .iso8601
            jsonDecorder.keyDecodingStrategy = .convertFromSnakeCase
            return try jsonDecorder.decode(Ticket.self, from: data)
        } catch  {
            print(error)
            return nil
        }
    }
}
