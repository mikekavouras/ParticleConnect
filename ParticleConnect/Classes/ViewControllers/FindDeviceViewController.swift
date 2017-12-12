//
//  FindDeviceViewController.swift
//  ParticleConnect
//
//  Created by Mike on 12/1/17.
//

import UIKit
import UserNotifications

internal class FindDeviceViewController: UIViewController {
    
    let loaderView: LoaderClass
    
    fileprivate var communicationManager: DeviceCommunicationManager?
    
    // MARK: Life cycle
    
    init(loaderClass: LoaderClass.Type? = nil) {
        if let customClass = loaderClass {
            loaderView = customClass.init(frame: .zero)
        }
        else {
            loaderView = LoaderView(frame: .zero)
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onConnectionHandler(notification:)), name: Notification.Name.ConnectedToParticleDevice, object: nil)
        
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        WiFi.shared?.startMonitoringConnectionInForeground()
        loaderView.show("Searching for device")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        WiFi.shared?.stopMonitoringConnectionInForeground()
        loaderView.hide()
        
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
        registerForLocalNotifications()
    }
    
    private func setupLoaderView() {
        view.addSubview(loaderView)
        
        let margin = view.layoutMarginsGuide
        loaderView.centerYAnchor.constraint(equalTo: margin.centerYAnchor, constant: -60).isActive = true
        loaderView.centerXAnchor.constraint(equalTo: margin.centerXAnchor).isActive = true
        loaderView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func registerForLocalNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { allowed, error in }
        UIApplication.shared.registerForRemoteNotifications()
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
            WiFi.shared?.stopMonitoringConnection()
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
                guard let weakSelf = self else { return }
                let viewController = SelectNetworkViewController(loaderClass: type(of: weakSelf.loaderView))
                weakSelf.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    private var retry = false
    private func getDeviceId(completion: @escaping (String) -> Void) {
        communicationManager = DeviceCommunicationManager()
        communicationManager?.sendCommand(Command.Device.self) { [weak self] result in
            switch result {
            case .success(let value):
                self?.communicationManager = nil
                completion(value.deviceId)
            case .failure(let error):
                self?.communicationManager = nil
                if error == ConnectionError.timeout {
                    if self != nil && !self!.retry {
                        self?.retry = true
                        self?.fetchDeviceId()
                    } else {
                        guard let viewController = self else { return }
                        UI.presentBasicAlert(in: viewController, message: "Could not get the device ID (timeout)")
                    }
                } else {
                    guard let viewController = self else { return }
                    UI.presentBasicAlert(in: viewController, message: "Could not get the device ID")
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
                self?.communicationManager = nil
                guard let viewController = self else { return }
                UI.presentBasicAlert(in: viewController, message: "Could not get the public key")
            }
        }
    }
}
