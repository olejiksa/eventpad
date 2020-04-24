//
//  BigButton.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 29.03.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import UIKit

final class BigButton: UIButton {
    
    // MARK: Public Properties
    
    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
    
    override var backgroundColor: UIColor? {
        get {
            return isEnabled ? .systemBlue : .systemFill
        }
        set {
            super.backgroundColor = isEnabled ? .systemBlue : .systemFill
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                UIView.animate(withDuration: 0) {
                    super.backgroundColor = .systemBlue
                }
            } else {
                UIView.animate(withDuration: 0) {
                    super.backgroundColor = .systemFill
                }
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                UIView.animate(withDuration: 0.3) {
                    super.backgroundColor = super.backgroundColor?.withAlphaComponent(0.5)
                }
            } else {
                UIView.animate(withDuration: 0.7) {
                    super.backgroundColor = super.backgroundColor?.withAlphaComponent(1.0)
                }
            }
        }
    }
    
    
    // MARK: Private Properties
    
    private var originalButtonText: String?
    private var activityIndicator: UIActivityIndicatorView?
    
    
    // MARK: Public
    
    func showLoading() {
        originalButtonText = titleLabel?.text
        setTitle("", for: .normal)

        if activityIndicator == nil {
            activityIndicator = createActivityIndicator()
        }

        showSpinning()
    }

    func hideLoading() {
        setTitle(originalButtonText, for: .normal)
        activityIndicator?.stopAnimating()
    }
    
    
    // MARK: Private
    
    private func createActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        return activityIndicator
    }

    private func showSpinning() {
        guard let activityIndicator = activityIndicator else { return }
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
        centerActivityIndicatorInButton()
        activityIndicator.startAnimating()
    }

    private func centerActivityIndicatorInButton() {
        let xCenterConstraint = NSLayoutConstraint(item: self,
                                                   attribute: .centerX,
                                                   relatedBy: .equal,
                                                   toItem: activityIndicator,
                                                   attribute: .centerX,
                                                   multiplier: 1,
                                                   constant: 0)
        addConstraint(xCenterConstraint)

        let yCenterConstraint = NSLayoutConstraint(item: self,
                                                   attribute: .centerY,
                                                   relatedBy: .equal,
                                                   toItem: activityIndicator,
                                                   attribute: .centerY,
                                                   multiplier: 1,
                                                   constant: 0)
        addConstraint(yCenterConstraint)
    }
}
