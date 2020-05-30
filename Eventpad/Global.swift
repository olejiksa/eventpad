//
//  Global.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 25.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import Foundation
import UIKit

struct Global {
    
    static var role: Role = .participant
    static var accessToken: String?
    static var categoryInUse: Category?
    static var location: String?
    static var deviceToken: String?
}


func convertImageToBase64(_ image: UIImage) -> String {
    let imageData = image.jpegData(compressionQuality: 0.4)! as Data
    let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
    return strBase64
}

func convertBase64ToImage(_ str: String) -> UIImage? {
    guard let dataDecoded = Data(base64Encoded: str, options: .ignoreUnknownCharacters) else { return nil }
    let decodedimage = UIImage(data: dataDecoded)
    return decodedimage
}
