//
//  UI.swift
//  ParticleConnect
//
//  Created by Mike on 12/3/17.
//

import UIKit

class UI {
    static func presentPasswordDialog(`for` network: Network, `in` viewController: UIViewController, completion: @escaping (UIAlertController) -> Void) {
        let alertController = UIAlertController(title: "Enter Password", message: "Enter the password for \(network.ssid)", preferredStyle: .alert)
        let passwordTextField = { (textField: UITextField) -> Void in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        alertController.addTextField(configurationHandler: passwordTextField)
        
        let submitAction = UIAlertAction(title: "Join", style: .default) { _ in
            completion(alertController)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alertController.addAction(cancelAction)
        alertController.addAction(submitAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
}
