//
//  ViewController.swift
//  ParticleConnect
//
//  Created by d8915d4c64a5f9654c7e3ca0a00fcac82db05acc on 11/30/2017.
//  Copyright (c) 2017 d8915d4c64a5f9654c7e3ca0a00fcac82db05acc. All rights reserved.
//

import UIKit
import ParticleConnect

enum PresentationStyle: String {
    case viewController = "view controller"
    case navigationController = "navigation controller"
    case customView = "custom view"
    
    static var all: [PresentationStyle] {
        return [.viewController, .navigationController, .customView]
    }
}

class ViewController: UITableViewController {
    
    private var selectedStyle: PresentationStyle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "ParticleConnect"
        NotificationCenter.default.addObserver(self, selector: #selector(dismissWizard(notification:)), name: Notification.Name.ParticleConnectNewDeviceConnectedSuccess, object: nil)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "style")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        selectedStyle = nil
    }

    @objc private func dismissWizard(notification: Notification) {
        guard let style = selectedStyle else { return }
        
        switch style {
        case .viewController, .customView:
            navigationController?.popToRootViewController(animated: true)
        case .navigationController:
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func dismissModal() {
        dismiss(animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PresentationStyle.all.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "style", for: indexPath)
        let styles = PresentationStyle.all
        cell.textLabel?.text = styles[indexPath.row].rawValue
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let styles = PresentationStyle.all
        let style = styles[indexPath.row]
        
        selectedStyle = style
        
        switch style {
        case .viewController:
            let viewController = ParticleConnectViewController(loaderClass: CustomLoaderView.self)
            navigationController?.pushViewController(viewController, animated: true)
        case .navigationController:
            let viewController = ParticleConnectViewController()
            let navigationController = UINavigationController(rootViewController: viewController)
            viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Dismiss", style: .plain, target: self, action: #selector(dismissModal))
            present(navigationController, animated: true, completion: nil)
        default:
            performSegue(withIdentifier: "CustomViewController", sender: self)
            break
        }
    }
}
