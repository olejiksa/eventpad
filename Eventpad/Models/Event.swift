//
//  Event.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 23.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

struct Event: Codable, Hashable {
    
    private enum CodingKeys: String, CodingKey {
        case id
        case dateStart = "date_start"
        case dateEnd = "date_end"
        case isLeaf = "is_leaf"
        case conferenceID = "conference_id"
        case speakerName = "speaker_login"
        case speakerID = "speaker_id"
        case title = "name"
        case description
        case photoUrl
    }
    
    let id: Int?
    let dateStart: Date
    let dateEnd: Date
    let isLeaf: Bool
    let conferenceID: Int
    let speakerName: String?
    let speakerID: Int?
    let title: String
    let description: String
    let photoUrl: String?
    
    var dateStartFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return formatter.string(from: dateStart)
    }
}
