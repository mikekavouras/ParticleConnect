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

public typealias LoaderViewType = LoadingRepresentable & UIView

public class ParticleConnectViewController: UIViewController {
    
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
        let findDeviceViewController = FindDeviceViewController(loaderViewType: loaderViewType)
        
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
