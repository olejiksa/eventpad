//
//  MainViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 28.03.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class MainViewController: UIViewController {
    
    private let cellID = "\(EventCell.self)"
    private let userDefaultsService = UserDefaultsService()
    
    private let refreshControl = UIRefreshControl()
    
    private lazy var sections: [Section] = [
        EventSection(),
        EventSection(),
        EventSection(),
        EventSection(),
        EventSection(),
        EventSection(),
        EventSection(),
        EventSection(),
        EventSection(),
        EventSection(),
        EventSection(),
        EventSection(),
        EventSection(),
        EventSection(),
        EventSection(),
        EventSection(),
    ]
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: -10, left: 0, bottom: 20, right: 0)

        collectionView.register(UINib(nibName: String(describing: EventCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: EventCell.self))

        return collectionView
    }()
    
    private lazy var collectionViewLayout: UICollectionViewLayout = {
        var sections = self.sections
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment -> NSCollectionLayoutSection? in
            return sections[sectionIndex].layoutSection()
        }
        return layout
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupCollectionView()
        setupRefreshControl()
    }
    
    private func setupNavigation() {
        navigationItem.title = "Афиша"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let userImage = UIImage(systemName: "person.crop.circle")
        let userButton = UIBarButtonItem(image: userImage,
                                         style: .plain,
                                         target: self,
                                         action: #selector(userDidTap))
        navigationItem.rightBarButtonItem = userButton
        
        let filterImage = UIImage(systemName: "line.horizontal.3.decrease.circle")
        let filterButton = UIBarButtonItem(image: filterImage,
                                           style: .plain,
                                           target: self,
                                           action: #selector(filterDidTap))
        
        let locationImage = UIImage(systemName: "location.circle")
        let locationButton = UIBarButtonItem(image: locationImage,
                                             style: .plain,
                                             target: self,
                                             action: #selector(filterDidTap))
        
        navigationItem.leftBarButtonItems = [locationButton, filterButton]
    }
    
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
    }
    
    private func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Потяните для обновления")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    @objc private func userDidTap() {
        if let user = userDefaultsService.getUser() {
            let vc = AccountViewController(user: user)
            let nvc = UINavigationController(rootViewController: vc)
            present(nvc, animated: true)
        } else {
            let vc = AuthViewController()
            let nvc = UINavigationController(rootViewController: vc)
            present(nvc, animated: true)
        }
    }
    
    @objc private func filterDidTap() {
        let vc = CategoriesViewController()
        let nvc = UINavigationController(rootViewController: vc)
        present(nvc, animated: true)
    }
    
    @objc private func refresh() {
        refreshControl.endRefreshing()
    }
}


// MARK: - UICollectionViewDataSource

extension MainViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return sections[indexPath.section].configureCell(collectionView: collectionView, indexPath: indexPath)
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return sections[section].numberOfItems
    }
}


// MARK: - UICollectionViewDelegate

extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = EventDetailViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}
