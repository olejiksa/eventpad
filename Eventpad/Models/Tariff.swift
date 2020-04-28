//
//  Tariff.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 20.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

struct Tariff: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title = "name"
        case price = "cost"
        case conferenceID = "conference_id"
        case ticketsLeftCount = "tickets_left"
        case ticketsTotalCount = "tickets_total"
    }
    
    let id: Int?
    let title: String
    let price: Double
    let conferenceID: Int
    let ticketsLeftCount: Int
    let ticketsTotalCount: Int
}
