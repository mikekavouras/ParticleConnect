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

enum SecurityType: UInt {
    case open              = 0           /**< Unsecured                               */
    case wep_psk           = 1           /**< WEP Security with open authentication   */
    case wep_shared        = 0x8001      /**< WEP Security with shared authentication */
    case wpa_tkip_psk      = 0x00200002  /**< WPA Security with TKIP                  */
    case wpa_aes_psk       = 0x00200004  /**< WPA Security with AES                   */
    case wpa2_aes_psk      = 0x00400004  /**< WPA2 Security with AES                  */
    case wpa2_aes_tkip_psk = 0x00400002  /**< WPA2 Security with TKIP                 */
    case wpa2_mixed_psk    = 0x00400006  /**< WPA2 Security with AES & TKIP           */
    
    var displayName: String {
        switch self {
        case .open:
            return "Open"
        case .wep_psk:
            return "WEP-PSK"
        case .wep_shared:
            return "WEP-SHARED"
        case .wpa_tkip_psk:
            return "WPA-TKIP"
        case .wpa_aes_psk:
            return "WPA-AES"
        case .wpa2_aes_psk:
            return "WPA2-AES"
        case .wpa2_aes_tkip_psk:
            return "WPA2-TKIP"
        case .wpa2_mixed_psk:
            return "WPA2-Mixed"
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
    
    var securityType: SecurityType? {
        return SecurityType(rawValue: sec)
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
