//
//  SuccessParser.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 22.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

final class SuccessParser: ParserProtocol {
    
    func parse(data: Data) -> BasicResponse? {
        do {
            let jsonDecorder = JSONDecoder()
            jsonDecorder.dateDecodingStrategy = .iso8601
            jsonDecorder.keyDecodingStrategy = .convertFromSnakeCase
            return try jsonDecorder.decode(BasicResponse.self, from: data)
        } catch  {
            print(error)
            return nil
        }
    }
}
