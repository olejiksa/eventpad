//
//  MessageResponse.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 23.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

struct MessageResponse: Decodable {

    let success: Bool
    let message: String
}
