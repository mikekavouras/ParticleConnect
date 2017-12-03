//
//  Wifi.swift
//  ParticleConnect
//
//  Created by Mike on 12/1/17.
//

import Foundation
import UIKit
import SystemConfiguration.CaptiveNetwork

extension Notification.Name {
    public static let ConnectedToParticleDevice = Notification.Name("ConnectedToParticleDevice")
}

public class Wifi {
    
    // MARK: - Public
    
    static let shared = Wifi()
    
    public init() {
        NotificationCenter.default.addObserver(self, selector: #selector(startMonitoringConnectionInForeground), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startMonitoringConnectionInBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    public func stopMonitoringConnectionInForeground() {
        foregroundTimer?.invalidate()
        foregroundTimer = nil
    }
    
    public func stopMonitoringConnection() {
        stopMonitoringConnectionInForeground()
        stopMonitoringConnectionInBackground()
        NotificationCenter.default.removeObserver(self)
    }
    
    public static func monitorForDisconnectingNetwork(completion: @escaping () -> Void) {
        var retries = 0
        func connect() {
            if Wifi.isDeviceConnected(.photon) == true && retries < 10 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    retries += 1
                    connect()
                }
            } else {
                if Wifi.isDeviceConnected(.photon) {
                    print("why are we still connected to the device?")
                } else {
                    completion()
                }
            }
        }
        connect()
    }
    
    /*
     Public: Kicks off a timer to run in the foreground. Every
     iteration checks to see if our phone is connected to the
     photon's onboard wifi
     
     Returns nil
     */
    @objc public func startMonitoringConnectionInForeground() {
        stopMonitoringConnectionInBackground()
        stopMonitoringConnectionInForeground()
        
        foregroundTimer = Timer(timeInterval: Wifi.foregroundTimerInterval, target: self, selector: #selector(checkDeviceWifiConnection(timer:)), userInfo: nil, repeats: true)
        
        RunLoop.current.add(foregroundTimer!, forMode: .commonModes)
        
        // kill the background task when we're in the foreground
        if let identifier = backgroundTaskIdentifier {
            UIApplication.shared.endBackgroundTask(identifier)
        }
    }
    
    // MARK: - Private
    
    static let foregroundTimerInterval = 1.0
    static let backgroundTimerInterval = 1.0
    
    private var foregroundTimer: Timer?
    private var backgroundTimer: Timer?
    
    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier? = nil
    
    /*
     Private: Kicks off a timer to run in the background. Every
     iteration checks to see if our phone is connected to the
     photon's onboard wifi.
     
     ** Important **
     This method creates a background task, causing the app
     to continue running even when the app is not in the foreground
     
     Returns nil
     */
    @objc private func startMonitoringConnectionInBackground() {
        stopMonitoringConnectionInForeground()
        
        backgroundTimer?.invalidate()
        backgroundTimer = nil
        backgroundTimer = Timer(timeInterval: Wifi.backgroundTimerInterval, target: self, selector: #selector(checkDeviceConnectionForNotification(timer:)), userInfo: nil, repeats: true)
        
        RunLoop.current.add(backgroundTimer!, forMode: .commonModes)
        
        // keep the app running in the background so our timer can continue firing
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask { [unowned self] in
            self.backgroundTimer?.invalidate()
            UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier!)
            self.backgroundTaskIdentifier = UIBackgroundTaskInvalid
        }
    }
    
    private func stopMonitoringConnectionInBackground() {
        backgroundTimer?.invalidate()
        backgroundTimer = nil
    }
 
    @objc private func checkDeviceConnectionForNotification(timer: Timer) {
        print("checking connection in the background")
        
        let state = UIApplication.shared.applicationState
        guard state == .background || state == .inactive,
            Wifi.isDeviceConnected(.photon) else { return }
        
        stopMonitoringConnectionInBackground()
        
        NotificationCenter.default.post(name: Notification.Name.ConnectedToParticleDevice, object: state)
    }
    
    @objc private func checkDeviceWifiConnection(timer: Timer) {
        print("checking connection in the foreground")

        let state = UIApplication.shared.applicationState
        guard state == .active,
            Wifi.isDeviceConnected(.photon) else { return }
        
        NotificationCenter.default.post(name: Notification.Name.ConnectedToParticleDevice, object: state)
    }
    
    
    // MARK: - Helper
    
    class func isDeviceConnected(_ deviceType: DeviceType) -> Bool {
        guard let interfaces = CNCopySupportedInterfaces() else { return false }
        
        for i in 0..<CFArrayGetCount(interfaces){
            let interfaceName: UnsafeRawPointer = CFArrayGetValueAtIndex(interfaces, i)
            let rec = unsafeBitCast(interfaceName, to: CFString.self)
            
            guard let interfaceData = CNCopyCurrentNetworkInfo(rec) as NSDictionary? else { continue }
            guard let currentSSID = interfaceData["SSID"] as? String else { continue }
            
            if currentSSID.hasPrefix(deviceType.rawValue) {
                return true
            }
        }
        
        return false
    }
}

