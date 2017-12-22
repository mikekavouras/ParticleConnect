//
//  ParticleConnectViewController.swift
//  Nimble
//
//  Created by Mike on 12/3/17.
//

import UIKit
import UserNotifications

public enum Theme {
    case light
    case dark
}

public extension Notification.Name {
    public static let ParticleConnectNewDeviceConnectedSuccess = Notification.Name("ParticleConnectNewDeviceConnectedSuccess")
}

public typealias LoaderViewType = LoadingRepresentable & UIView

public class ParticleConnectViewController: UIViewController {
    
    var theme: Theme = .light
    
    private let loaderViewType: LoaderViewType.Type?
    
    public init(loaderViewType: LoaderViewType.Type? = nil) {
        self.loaderViewType = loaderViewType
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    private func setup() {
        setupInitialViewController()
        registerForLocalNotifications()
    }
    
    
    private func registerForLocalNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { allowed, error in }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    private func setupInitialViewController() {
        let findDeviceViewController = FindDeviceViewController(loaderViewType: loaderViewType)
//        findDeviceViewController.theme = theme
        
        addChildViewController(findDeviceViewController)
        view.addSubview(findDeviceViewController.view)
        
        // auto layout
        let margins = view.layoutMarginsGuide
        findDeviceViewController.view.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        findDeviceViewController.view.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        findDeviceViewController.view.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        findDeviceViewController.view.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        findDeviceViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        findDeviceViewController.didMove(toParentViewController: self)
    }
}
