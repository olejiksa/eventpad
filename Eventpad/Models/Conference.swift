//
//  Conference.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 22.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

struct Conference: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title = "name"
        case description
        case category
        case tariffs
        case location
        case dateStart = "date_start"
        case dateEnd = "date_end"
        case isCancelled = "is_cancelled"
        case organizerName = "organizer_login"
        case organizerID = "organizer_id"
    }
    
    let id: Int?
    let title: String
    let description: String
    let category: Category
    let tariffs: [Tariff]
    let location: String
    let dateStart: Date
    let dateEnd: Date
    let isCancelled: Bool
    let organizerName: String?
    let organizerID: String?
}
