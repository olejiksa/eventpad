//
//  Category.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 20.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

enum Category: Int, CaseIterable, Codable {
    
    case noCategory
    case politics
    case society
    case economics
    case sport
    case culture
    case tech
    case science
    case auto
    case other
    
    init?(string: String) {
        var value: Category = .noCategory
        for item in Category.allCases {
            if item.description == string {
                value = item
                break
            }
        }
        
        self.init(rawValue: value.rawValue)
    }
}


// MARK: - CustomStringConvertible

extension Category: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .noCategory:
            return "Без категории"
            
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
            
        case .other:
            return "Другое"
        }
    }
}
