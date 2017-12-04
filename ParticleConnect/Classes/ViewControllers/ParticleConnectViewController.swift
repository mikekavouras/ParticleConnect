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
        let findDeviceViewController = FindDeviceViewController()
        
        addChildViewController(findDeviceViewController)
        view.addSubview(findDeviceViewController.view)
        
        // auto layout
        let margins = view.layoutMarginsGuide
        findDeviceViewController.view.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        findDeviceViewController.view.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        findDeviceViewController.view.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        findDeviceViewController.view.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        
        findDeviceViewController.didMove(toParentViewController: self)
    }
}
