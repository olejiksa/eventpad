//
//  ConferencesParser.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 23.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

final class ConferencesParser: ParserProtocol {
    
    func parse(data: Data) -> [Conference]? {
        do {
            let jsonDecorder = JSONDecoder()
            jsonDecorder.dateDecodingStrategy = .custom(customDateDecoder)
            return try jsonDecorder.decode([Conference].self, from: data)
        } catch  {
            print(error)
            return nil
        }
    }
    
    private func customDateDecoder(decoder: Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let str = try container.decode(String.self)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: str)
        return date ?? Date()
    }
}
