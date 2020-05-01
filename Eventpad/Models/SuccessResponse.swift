//
//  SuccessResponse.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 16.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

struct SuccessResponse: Decodable {

    let success: Bool
    let message: String?
}
