//
//  MyConferencesViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 27.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class MyConferencesViewController: UIViewController {

    private let cellID = "\(ConferenceCell.self)"
    private let requestSender = RequestSender()
    private let alertService = AlertService()
    private let userDefaultsService = UserDefaultsService()
    
    private let refreshControl = UIRefreshControl()
    private var sections: [EventSection]
    
    init(sections: [EventSection]) {
        self.sections = sections
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var noDataLabel: UILabel = {
        let label = UILabel()
        label.text = "Нет конференций"
        label.textColor = UIColor.secondaryLabel
        label.isHidden = true
        return label
    }()
    
    private var collectionView: UICollectionView!
    private var collectionViewLayout: UICollectionViewLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupCollectionView()
        setupNoDataLabel()
        setupRefreshControl()
        loadData()
    }

    private func setupNavigation() {
        navigationItem.title = "Мои конференции"
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(addDidTap))
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func setupCollectionView() {
        collectionViewLayout = UICollectionViewCompositionalLayout { [weak self] index, _ -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            return self.sections[index].layoutSection()
        }
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)

        let nib = UINib(nibName: cellID, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: cellID)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
    }
    
    private func setupNoDataLabel() {
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noDataLabel)
        
        NSLayoutConstraint.activate([
            noDataLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noDataLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func loadData() {
        guard let user = userDefaultsService.getUser() else { return }
        
        let config = RequestFactory.conferences(username: user.username, limit: 20, offset: 0)
        requestSender.send(config: config) { [weak self] result in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()

            switch result {
            case .success(let conferences):
                self.sections = conferences.sorted(by: { $0.dateStart > $1.dateStart}).map { EventSection(conference: $0) }
                self.noDataLabel.isHidden = !conferences.isEmpty
                self.collectionView.reloadData()
                
            case .failure(let error):
                let alert = self.alertService.alert(error.localizedDescription)
                self.present(alert, animated: true)
            }
        }
    }
    
    @objc private func addDidTap() {
        let vc = NewConferenceViewController(mode: .new)
        let nvc = UINavigationController(rootViewController: vc)
        present(nvc, animated: true)
    }
    
    @objc private func refresh() {
        loadData()
    }
}


// MARK: - UICollectionViewDataSource

extension MyConferencesViewController: UICollectionViewDataSource {
    
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

extension MyConferencesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let conference = sections[indexPath.section].conference
        let vc = ConferenceViewController(conference: conference, isManager: true)
        navigationController?.pushViewController(vc, animated: true)
    }
}
