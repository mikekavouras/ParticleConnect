//
//  ViewController.swift
//  ParticleConnect
//
//  Created by d8915d4c64a5f9654c7e3ca0a00fcac82db05acc on 11/30/2017.
//  Copyright (c) 2017 d8915d4c64a5f9654c7e3ca0a00fcac82db05acc. All rights reserved.
//

import UIKit
import ParticleConnect

class ViewController: UIViewController {
    var shownWizard = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        if !shownWizard {
            shownWizard = true
            let viewController = ParticleConnectViewController()
            present(viewController, animated: true, completion: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(dismissWizard(notification:)), name: Notification.Name.ParticleConnectNewDeviceConnectedSuccess, object: nil)
        }
    }
    
    @objc private func dismissWizard(notification: Notification) {
        dismiss(animated: true, completion: nil)
    }
}

