//
//  CustomViewController.swift
//  ParticleConnect_Example
//
//  Created by Mike on 12/3/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import ParticleConnect

class CustomViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.layer.shadowOffset = .init(width: 2, height: 2)
            containerView.layer.shadowColor = UIColor.black.cgColor
            containerView.layer.shadowRadius = 30.0
            containerView.layer.shadowOpacity = 0.2
            containerView.layer.cornerRadius = 20.0
        }
    }
    
    @IBOutlet weak var customView: UIView! {
        didSet {
            customView.layer.cornerRadius = 20.0
            customView.layer.masksToBounds = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewController = ParticleConnectViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        
        addChildViewController(navigationController)
        customView.addSubview(navigationController.view)
        
        let margins = customView.layoutMarginsGuide
        navigationController.view.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: -8).isActive = true
        navigationController.view.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 8).isActive = true
        navigationController.view.topAnchor.constraint(equalTo: margins.topAnchor, constant: -8).isActive = true
        navigationController.view.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: 8).isActive = true
        
        navigationController.view.translatesAutoresizingMaskIntoConstraints = false
        
        navigationController.didMove(toParentViewController: self)
    }
}
