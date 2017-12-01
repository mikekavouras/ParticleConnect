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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let viewController = FindDeviceViewController()
        viewController.view.backgroundColor = .white
        
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true, completion: nil)
    }
}

