//
//  Conference.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 22.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation

struct Conference {
    
    let title: String
    let description: String
    let category: Category
    let location: String
    let dateStart: Date
    let dateEnd: Date
    let isCancelled: Bool
    let organizerLogin: String
}
