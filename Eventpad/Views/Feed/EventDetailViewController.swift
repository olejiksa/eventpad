//
//  EventDetailViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 02.04.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import MapKit
import UIKit

final class EventDetailViewController: UIViewController {
    
    private let userDefaultsService = UserDefaultsService()
    private let conference: Conference
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateTimeLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var categoryLabel: UILabel!
    
    init(conference: Conference) {
        self.conference = conference
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupView()
    }
    
    private func setupNavigation() {
        navigationItem.title = "Конференция"
        navigationItem.largeTitleDisplayMode = .never
        
        let shareImage = UIImage(systemName: "square.and.arrow.up")
        let shareButton = UIBarButtonItem(image: shareImage,
                                         style: .plain,
                                         target: self,
                                         action: #selector(shareDidTap))
        
        let favoriteImage = UIImage(systemName: "star")
        let favoriteButton = UIBarButtonItem(image: favoriteImage,
                                             style: .plain,
                                             target: self,
                                             action: #selector(shareDidTap))
        navigationItem.rightBarButtonItems = [shareButton, favoriteButton]
    }
    
    private func setupView() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d"
        let date = dateFormatter.string(from: conference.dateStart)
        
        titleLabel.text = conference.title
        dateTimeLabel.text = date
        descriptionLabel.text = conference.description
        categoryLabel.text = conference.category.description
    }
    
    @IBAction private func registerDidTap() {
        if userDefaultsService.getToken() == nil {
            let vc = AuthViewController()
            let nvc = UINavigationController(rootViewController: vc)
            present(nvc, animated: true)
        }
    }
    
    @IBAction private func openMapDidTap() {
        let regionDistance: CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(-78.07020, -75.98125)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = conference.title
        mapItem.openInMaps(launchOptions: options)
    }
    
    @objc private func shareDidTap() {
        let text = conference.title
        let url = URL(string: "http://www.google.com")!
        let sharedObjects = [url as AnyObject, text as AnyObject]
        let activityViewController = UIActivityViewController(activityItems: sharedObjects, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        present(activityViewController, animated: true, completion: nil)
    }
}
