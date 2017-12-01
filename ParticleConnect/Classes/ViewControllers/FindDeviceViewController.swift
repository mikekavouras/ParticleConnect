//
//  FindDeviceViewController.swift
//  ParticleConnect
//
//  Created by Mike on 12/1/17.
//

import UIKit
import UserNotifications

public class FindDeviceViewController: UIViewController {
    
    fileprivate lazy var wifi: Wifi = {
        return Wifi { [weak self] state in
            self?.onConnectionHandler(state: state)
        }
    }()
    
    fileprivate var communicationManager: DeviceCommunicationManager?
    fileprivate var deviceId: String = ""
    
    fileprivate var deviceConnectRetryCount: Int = 0
    
    
    // MARK: Life cycle
    
    public override func viewDidLoad() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { allowed, error in }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        wifi.startMonitoringConnection()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        wifi.stopMonitoringConnectionInForeground()
    }
    
    deinit {
        wifi.stopMonitoringConnection()
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
    
    func onConnectionHandler(state: UIApplicationState) {
        if state == .background || state == .inactive {
            displayLocalNotification()
        }
        if state == .active {
            wifi.stopMonitoringConnection()
            print("connected in the foreground")
//            getDeviceId { [weak self] id in
//                print("device id: \(id)")
//                self?.getPublicKey { [weak self] in
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        print("got our public key!")
//                        let networkViewController = SelectNetworkViewController()
//                        networkViewController.deviceId = id
//                        self?.navigationController?.pushViewController(networkViewController, animated: true)
//                    }
//                }
//            }
        }
    }
    
    
    // MARK: -
    
    private func getDeviceId(completion: @escaping (String) -> Void) {
//        communicationManager = DeviceCommunicationManager()
//        communicationManager?.sendCommand(Command.Device.self) { [weak self] result in
//            switch result {
//            case .success(let value):
//                completion(value.deviceId)
//            case .failure(let error):
//                if error == ConnectionError.timeout {
//                    if self != nil && self!.deviceConnectRetryCount >= 5 {
//                        self?.showConnectionFailureAlert()
//                        return
//                    }
//                    self?.deviceConnectRetryCount += 1
//                    self?.wifi.startMonitoringConnectionInForeground()
//                } else {
//                    self?.showConnectionFailureAlert()
//                }
//            }
//        }
    }
    
    private func getPublicKey(completion: @escaping () -> Void) {
//        communicationManager = DeviceCommunicationManager()
//        communicationManager!.sendCommand(Command.PublicKey.self) { [weak self] result in
//            switch result {
//            case .success:
//                completion()
//            case .failure:
//                self?.wifi.startMonitoringConnectionInForeground()
//            }
//        }
    }
    
    
    // MARK: -
    
    private func showConnectionFailureAlert() {
        let action = UIAlertAction(title: "Try again", style: .default) { action in
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        let alert = UIAlertController(title: "Could not connect", message: "We're having trouble connecting to your device. Double check your device is on and ready to connect (blinking blue).", preferredStyle: .alert)
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
}


