//
//  Wifi.swift
//  ParticleConnect
//
//  Created by Mike on 12/1/17.
//

import Foundation
import UIKit
import SystemConfiguration.CaptiveNetwork

public class Wifi {
    
    // MARK: - Public
    
    public init(_ connectionBlock: @escaping (UIApplicationState) -> Void) {
        self.onConnectionHandler = connectionBlock
        NotificationCenter.default.addObserver(self, selector: #selector(startMonitoringConnectionInForeground), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    public func startMonitoringConnection() {
        startMonitoringConnectionInForeground()
        startMonitoringConnectionInBackground()
    }
    
    public func stopMonitoringConnectionInForeground() {
        foregroundTimer?.invalidate()
    }
    
    public func stopMonitoringConnection() {
        stopMonitoringConnectionInForeground()
        stopMonitoringConnectionInBackground()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private
    
    static let foregroundTimerInterval = 1.0
    static let backgroundTimerInterval = 2.0
    
    private let onConnectionHandler: (UIApplicationState) -> Void
    private var foregroundTimer: Timer?
    private var backgroundTimer: Timer?
    
    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier? = nil
    
    @objc private func startMonitoringConnectionInForeground() {
        foregroundTimer?.invalidate()
        foregroundTimer = nil
        foregroundTimer = Timer(timeInterval: Wifi.foregroundTimerInterval, target: self, selector: #selector(checkDeviceWifiConnection(timer:)), userInfo: nil, repeats: true)
        
        RunLoop.current.add(foregroundTimer!, forMode: .commonModes)
        
        // kill the background task when we're in the foreground
        if let identifier = backgroundTaskIdentifier {
            UIApplication.shared.endBackgroundTask(identifier)
        }
    }
    
    private func startMonitoringConnectionInBackground() {
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
    }
    
    @objc private func checkDeviceConnectionForNotification(timer: Timer) {
        let state = UIApplication.shared.applicationState
        guard state == .background || state == .inactive,
            Wifi.isDeviceConnected(.photon) else { return }
        
        stopMonitoringConnectionInBackground()
        
        onConnectionHandler(state)
    }
    
    @objc private func checkDeviceWifiConnection(timer: Timer) {
        let state = UIApplication.shared.applicationState
        guard state == .active,
            Wifi.isDeviceConnected(.photon) else { return }
        
        onConnectionHandler(state)
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

