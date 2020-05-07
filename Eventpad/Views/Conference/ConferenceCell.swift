//
//  ConferenceCell.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 31.03.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class ConferenceCell: UICollectionViewCell {
    
    @IBOutlet private weak var view: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        view.layer.cornerRadius = 10
        imageView.layer.cornerRadius = 10
    }
    
    func configure(with conference: Conference) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d"
        let date = dateFormatter.string(from: conference.dateStart)
        
        titleLabel.text = conference.title
        subtitleLabel.text = "\(date) | \(conference.location) | \(conference.category.description)"
    }
}
