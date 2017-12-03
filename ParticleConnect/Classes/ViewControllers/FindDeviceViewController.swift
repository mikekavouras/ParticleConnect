//
//  FindDeviceViewController.swift
//  ParticleConnect
//
//  Created by Mike on 12/1/17.
//

import UIKit
import UserNotifications

public class FindDeviceViewController: UIViewController {
    
    let loaderView = LoaderView(frame: .zero)
    
    fileprivate var communicationManager: DeviceCommunicationManager?
    private var retryCount = 0
    
    // MARK: Life cycle
    
    public override func viewDidLoad() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { allowed, error in }
        UIApplication.shared.registerForRemoteNotifications()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onConnectionHandler(notification:)), name: Notification.Name.ConnectedToParticleDevice, object: nil)
        
        setup()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Wifi.shared.startMonitoringConnectionInForeground()
        
        loaderView.show("Searching for device")
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Wifi.shared.stopMonitoringConnectionInForeground()
        
        loaderView.hide()
    }
    
    deinit {
        Wifi.shared.stopMonitoringConnection()
    }
    
    // MARK: Setup
    
    private func setup() {
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
    
    @objc private func onConnectionHandler(notification: Notification) {
        guard let state = notification.object as? UIApplicationState else { return }
        
        if state == .background || state == .inactive {
            displayLocalNotification()
        }
        if state == .active {
            Wifi.shared.stopMonitoringConnection()
            print("connected in the foreground")
            
            loaderView.setText("Getting device ID")
            
            fetchDeviceId()
        }
    }
    
    // MARK: -
    
    private func fetchDeviceId() {
        getDeviceId { [weak self] deviceId in
            print("device id: \(deviceId)")
            self?.getPublicKey { [weak self] in
                let viewController = SelectNetworkViewController()
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    private func getDeviceId(completion: @escaping (String) -> Void) {
        communicationManager = DeviceCommunicationManager()
        communicationManager?.sendCommand(Command.Device.self) { [weak self] result in
            switch result {
            case .success(let value):
                self?.communicationManager = nil
                completion(value.deviceId)
            case .failure(let error):
                print(error)
                if error == ConnectionError.timeout {
                    if self != nil && self!.retryCount < 2 {
                        self?.retryCount += 1
                        self?.fetchDeviceId()
                    } else {
                        self?.showFailureAlert("Could not get the device ID (timeout)")
                    }
                } else {
                    self?.showFailureAlert("Could not get the device ID")
                }
            }
        }
    }
    
    private func getPublicKey(completion: @escaping () -> Void) {
        print("get public key")
        communicationManager = DeviceCommunicationManager()
        communicationManager!.sendCommand(Command.PublicKey.self) { [weak self] result in
            switch result {
            case .success:
                self?.communicationManager = nil
                print("public key: \(result)")
                completion()
            case .failure:
                self?.showFailureAlert("Could not get the public key")
            }
        }
    }
    
    // MARK: -
    
    private func showFailureAlert(_ message: String) {
        let action = UIAlertAction(title: "Damn", style: .default)
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
}


