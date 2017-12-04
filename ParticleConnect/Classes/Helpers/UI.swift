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
    
    static func presentBasicAlert(`in` viewController: UIViewController, message: String) {
        let action = UIAlertAction(title: "Damn", style: .default)
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            
        alert.addAction(action)
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
