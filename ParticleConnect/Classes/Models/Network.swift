//
//  Network.swift
//  Nimble
//
//  Created by Mike on 12/1/17.
//

func ==(lhs: Network, rhs: Network) -> Bool {
    return lhs.ssid == rhs.ssid
}

enum SignalStrength {
    case weak
    case medium
    case strong
    
    var asset: UIImage {
        switch self {
        case .weak:
            return UIImage.particleAsset(named: "wifi_weak")
        case .medium:
            return UIImage.particleAsset(named: "wifi_medium")
        case .strong:
            return UIImage.particleAsset(named: "wifi_strong")
        }
    }
}

struct Network: Equatable, Hashable {
    
    static let SignalStrengthThresholdStrong = -56
    static let SignalStrengthThresholdWeak = -71
    
    let sec: UInt
    let mdr: UInt
    let ssid: String
    let rssi: Int
    let ch: Int
    
    var isLocked: Bool {
        return sec > 0
    }

    var signalStrength: SignalStrength {
        if rssi > Network.SignalStrengthThresholdStrong {
            return .strong
        }
        if rssi > Network.SignalStrengthThresholdWeak {
            return .medium
        }
        return .weak
    }
    
    var password: String = ""
    
    init(json: [AnyHashable: Any]) {
        sec =  (json["sec"] as? UInt) ?? 0
        mdr =  (json["mdr"] as? UInt) ?? 0
        ssid = (json["ssid"] as? String) ?? "unknown"
        rssi = (json["rssi"] as? Int) ?? 0
        ch =   (json["ch"] as? Int) ?? 0
    }
    
    var asJSON: [AnyHashable: Any]? {
        guard let publicKey = try! Security.getPublicKey(),
            let passwordData = password.data(using: .utf8),
            let cipherData = Security.encryptWith(publicKey: publicKey, plainText: passwordData),
            let hexPassword = try! Security.encode(toHexString: cipherData) else
        {
            return nil
        }
        
        let request: [AnyHashable: Any] = [
            "idx" : 0,
            "ssid": ssid,
            "pwd": hexPassword,
            "sec": sec,
            "ch": ch
        ]
        
        return request
    }
    
    // MARK: - Hashable
    
    var hashValue: Int {
        return Int(sec)
    }
}
