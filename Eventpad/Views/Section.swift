//
//  Section.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 31.03.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

protocol Section {
    
    var numberOfItems: Int { get }
    
    func layoutSection() -> NSCollectionLayoutSection
    func configureCell(collectionView: UICollectionView,
                       indexPath: IndexPath) -> UICollectionViewCell
}

struct EventSection: Section {
    
    private let cellID = "\(ConferenceCell.self)"
    let conference: Conference
    let numberOfItems = 1
    
    init(conference: Conference) {
        self.conference = conference
    }

    func layoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let height = UIScreen.main.bounds.width - 17.5
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(height))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        return section
    }

    func configureCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as? ConferenceCell else { return .init() }
        
        cell.configure(with: conference)
        
        if let url = conference.photoUrl {
            let url = URL(string: url)
            cell.imageView.kf.setImage(with: url)
        }
        return cell
    }
}
