//
//  ParticleConnectViewController.swift
//  Nimble
//
//  Created by Mike on 12/3/17.
//

import UIKit

public extension Notification.Name {
    public static let ParticleConnectNewDeviceConnectedSuccess = Notification.Name("ParticleConnectNewDeviceConnectedSuccess")
}

public class ParticleConnectViewController: UIViewController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    private func setup() {
        setupNavigationController()
    }
    
    private func setupNavigationController() {
        let findDeviceViewController = FindDeviceViewController()
        let navigationController = UINavigationController(rootViewController: findDeviceViewController)
        
        addChildViewController(navigationController)
        view.addSubview(navigationController.view)
        
        // auto layout
        let margins = view.layoutMarginsGuide
        navigationController.view.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        navigationController.view.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        navigationController.view.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        navigationController.view.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        
        navigationController.didMove(toParentViewController: self)
    }
}
