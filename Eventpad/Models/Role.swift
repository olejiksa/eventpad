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
}


extension Role: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .organizer:
            return "Организатор"
            
        case .participant:
            return "Гость"
        }
    }
}
