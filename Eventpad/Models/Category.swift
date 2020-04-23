//
//  Category.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 20.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

enum Category: Int, Codable {
    
    case noCategory
    case politics
    case society
    case economics
    case sport
    case culture
    case tech
    case science
    case auto
}


// MARK: - CustomStringConvertible

extension Category: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .politics:
            return "Политика"
            
        case .society:
            return "Общество"
            
        case .economics:
            return "Экономика"
            
        case .sport:
            return "Спорт"
            
        case .culture:
            return "Культура"
            
        case .tech:
            return "Технологии"
            
        case .science:
            return "Наука"
            
        case .auto:
            return "Авто"
            
        default:
            return "Без категории"
        }
    }
}
