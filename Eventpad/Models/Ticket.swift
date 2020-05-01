//
//  Ticket.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 23.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

struct Ticket: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case id
        case released
        case tariffID = "tariff_id"
        case buyerID = "buyer_id"
    }
    
    let id: Int?
    let released: Date
    let tariffID: Int
    let buyerID: Int
}
