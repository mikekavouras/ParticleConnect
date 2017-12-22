//
//  FindDeviceViewController.swift
//  ParticleConnect
//
//  Created by Mike on 12/1/17.
//

import UIKit
import UserNotifications

internal class FindDeviceViewController: UIViewController, DeviceCommunicationManagerDelegate {
    
    let loaderView: LoaderViewType
    
    var theme: Theme = .light {
        didSet {
//            updateThemeUI()
        }
    }
    
    fileprivate var communicationManager: DeviceCommunicationManager?
    
    // MARK: Life cycle
    
    init(loaderViewType: LoaderViewType.Type? = nil) {
        if let customType = loaderViewType {
            loaderView = customType.init(frame: .zero)
        }
        else {
            loaderView = ParticleLoaderView(frame: .zero)
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        communicationManager = DeviceCommunicationManager()
        communicationManager?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDeviceWiFiConnectionHandler(notification:)), name: Notification.Name.ConnectedToParticleDevice, object: nil)
        WiFi.shared?.startMonitoringConnectionInForeground()
        
        loaderView.show("Searching for device")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        WiFi.shared?.stopMonitoringConnectionInForeground()
        loaderView.hide(nil)
        communicationManager = nil
        
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        WiFi.shared?.stopMonitoringConnection()
        WiFi.shared = nil
    }
    
    // MARK: Setup
    
    private func setup() {
        view.backgroundColor = .white
        
        WiFi.shared = WiFi()
        setupLoaderView()
    }
    
    private func setupLoaderView() {
        view.addSubview(loaderView)
        
        let margin = view.layoutMarginsGuide
        loaderView.centerYAnchor.constraint(equalTo: margin.centerYAnchor, constant: -60).isActive = true
        loaderView.centerXAnchor.constraint(equalTo: margin.centerXAnchor).isActive = true
        loaderView.translatesAutoresizingMaskIntoConstraints = false
    }

    
    // MARK: Notification
    
    private func displayLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Device Connected!"
        content.body = "Tap to continue Setup"
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.2, repeats: false)
        let request = UNNotificationRequest(identifier: "ConnectedIdentifier", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    
    // MARK: Navigation
    
    @objc private func onDeviceWiFiConnectionHandler(notification: Notification) {
        guard let state = notification.object as? UIApplicationState else { return }
        
        if state == .background || state == .inactive {
            displayLocalNotification()
        }
        if state == .active {
            print("connected in the foreground")

            WiFi.shared?.stopMonitoringConnection()
            loaderView.setText("Getting device ID")
            communicationManager?.getDeviceId()
        }
    }
}

// MARK - DeviceCommunicationManagerDelegate

extension FindDeviceViewController {
    func deviceCommunicationManager(deviceCommunicationManager: DeviceCommunicationManager, didReceiveDeviceId deviceId: String) {
        print("device id: \(deviceId)")
        communicationManager?.getPublicKey()
    }
    
    func deviceCommunicationManagerFailedToReceiveDeviceId(deviceCommunicationManager: DeviceCommunicationManager) {
        UI.presentBasicAlert(in: self, message: "Could not get the device ID (timeout)")
    }
    
    func deviceCommunicationManagerDidReceivePublicKey(deviceCommunicationManager: DeviceCommunicationManager) {
        print("received public key")
        let viewController = SelectNetworkViewController(loaderViewType: type(of: self.loaderView))
//        viewController.deviceId = deviceId
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func deviceCommunicationManagerFailedToReceivePublicKey(deviceCommunicationManager: DeviceCommunicationManager) {
        UI.presentBasicAlert(in: self, message: "Could not get the public key")
    }
}
