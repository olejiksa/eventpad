//
//  FeeViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 28.03.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class FeedViewController: UIViewController {
    
    private let cellID = "\(ConferenceCell.self)"
    private let requestSender = RequestSender()
    private let alertService = AlertService()
    private let userDefaultsService = UserDefaultsService()
    
    private let refreshControl = UIRefreshControl()
    private var sections = [EventSection]()
    
    private lazy var noDataLabel: UILabel = {
        let label = UILabel()
        label.text = "Нет конференций"
        label.textColor = UIColor.secondaryLabel
        label.isHidden = true
        return label
    }()
    
    private var collectionView: UICollectionView!
    private var collectionViewLayout: UICollectionViewLayout!
    private var spinner = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupCollectionView()
        setupNoDataLabel()
        setupRefreshControl()
        loadData()
        setupSpinner()
    }
    
    private func setupNavigation() {
        navigationItem.title = "Афиша"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let userImage = UIImage(systemName: "person.crop.circle")
        let userButton = UIBarButtonItem(image: userImage,
                                         style: .plain,
                                         target: self,
                                         action: #selector(userDidTap))
        
        navigationItem.rightBarButtonItems = [userButton]
        
        let filterImage = UIImage(systemName: "line.horizontal.3.decrease.circle")
        let filterButton = UIBarButtonItem(image: filterImage,
                                           style: .plain,
                                           target: self,
                                           action: #selector(filterDidTap))
        
        let locationImage = UIImage(systemName: "location.circle")
        let locationButton = UIBarButtonItem(image: locationImage,
                                             style: .plain,
                                             target: self,
                                             action: #selector(locationDidTap))
        
        navigationItem.leftBarButtonItems = [locationButton, filterButton]
    }
    
    private func setupCollectionView() {
        collectionViewLayout = UICollectionViewCompositionalLayout { [weak self] index, _ -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            return self.sections[index].layoutSection(self.view)
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
    
    private func setupSpinner() {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        spinner.startAnimating()
    }
    
    private func loadData() {
        if let category = Global.categoryInUse {
            let config = RequestFactory.conferences(categoryID: category.rawValue, limit: 20, offset: 0)
            requestSender.send(config: config) { [weak self] result in
                guard let self = self else { return }
                self.refreshControl.endRefreshing()
                self.spinner.stopAnimating()

                switch result {
                case .success(let conferences):
                    let results = Global.location != nil ? conferences.filter { $0.location == Global.location } : conferences
                    self.sections = results
                        .sorted { $0.dateStart > $1.dateStart }
                        .map { EventSection(conference: $0) }
                    self.noDataLabel.isHidden = !conferences.isEmpty
                    self.collectionView.reloadData()
                    
                case .failure(let error):
                    let alert = self.alertService.alert(error.localizedDescription)
                    self.present(alert, animated: true)
                }
            }
        } else {
            let config = RequestFactory.conferences(limit: 20, offset: 0)
            requestSender.send(config: config) { [weak self] result in
                guard let self = self else { return }
                self.refreshControl.endRefreshing()
                self.spinner.stopAnimating()
                
                switch result {
                case .success(let conferences):
                    let results = Global.location != nil ? conferences.filter { $0.location == Global.location } : conferences
                    self.sections = results
                        .sorted { $0.dateStart > $1.dateStart }
                        .map { EventSection(conference: $0) }
                    self.noDataLabel.isHidden = !conferences.isEmpty
                    self.collectionView.reloadData()
                    
                case .failure(let error):
                    let alert = self.alertService.alert(error.localizedDescription)
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    @objc private func userDidTap() {
        if let user = userDefaultsService.getUser() {
            let vc = AccountViewController(user: user, role: Global.role, isNotMine: false)
            if let splitVc = splitViewController, !splitVc.isCollapsed {
                (splitVc.viewControllers.last as? UINavigationController)?.pushViewController(vc, animated: true)
            } else {
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            let vc = AuthViewController()
            let nvc = UINavigationController(rootViewController: vc)
            nvc.modalPresentationStyle = .formSheet
            present(nvc, animated: true)
        }
    }
    
    @objc private func filterDidTap() {
        let vc = CategoriesViewController()
        let nvc = UINavigationController(rootViewController: vc)
        nvc.modalPresentationStyle = .formSheet
        present(nvc, animated: true)
    }
    
    @objc private func refresh() {
        loadData()
    }
    
    @objc private func locationDidTap() {
        let vc = LocationViewController()
        let nvc = UINavigationController(rootViewController: vc)
        nvc.modalPresentationStyle = .formSheet
        present(nvc, animated: true)
    }
}


// MARK: - UICollectionViewDataSource

extension FeedViewController: UICollectionViewDataSource {
    
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

extension FeedViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let conference = sections[indexPath.section].conference
        let vc = ConferenceViewController(conference: conference, isManager: false)
        if let splitVc = splitViewController, !splitVc.isCollapsed {
            (splitVc.viewControllers.last as? UINavigationController)?.pushViewController(vc, animated: true)
        } else {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}


// MARK: - UISplitViewControllerDelegate

extension FeedViewController: UISplitViewControllerDelegate {
    
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
