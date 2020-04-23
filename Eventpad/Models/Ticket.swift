//
//  Ticket.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 23.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

struct Ticket: Codable {
    
    let id: Int?
    let released: Date?
    let tariffID: Int
    let buyerID: Int
}
