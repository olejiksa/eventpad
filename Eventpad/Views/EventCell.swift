//
//  EventCell.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 31.03.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class EventCell: UICollectionViewCell {
    
    @IBOutlet private weak var view: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        view.layer.cornerRadius = 10
        imageView.layer.cornerRadius = 10
    }
}
