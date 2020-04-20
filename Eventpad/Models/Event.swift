//
//  Event.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 20.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

struct Event: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case title = "name"
        case description
        case location
        case category
        case tariffs
        case dateStart = "date_start"
        case dateEnd = "date_end"
        case organizerID = "organizer_id"
        case isCancelled = "is_cancelled"
    }
    
    let id: Int
    let title: String
    let description: String
    let location: String
    let category: Category
    let tariffs: [Tariff]
    let dateStart: Date
    let dateEnd: Date
    let organizerID: Int
    let isCancelled: Bool
}
