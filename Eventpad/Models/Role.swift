//
//  Role.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 23.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

enum Role {
    
    case organizer
    case participant
    case speaker
    case moderator
    
    var name: String {
        switch self {
        case .organizer:
            return "organizer"
            
        case .participant:
            return "participant"
            
        case .speaker:
            return "speaker"
        
        case .moderator:
            return "moderator"
        }
    }
}


// MARK: - CustomStringConvertible

extension Role: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .organizer:
            return "Организатор"
            
        case .participant:
            return "Гость"
            
        case .speaker:
            return "Спикер"
            
        case .moderator:
            return "Модератор"
        }
    }
}
