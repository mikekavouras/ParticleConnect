//
//  Command+Device.swift
//  ParticleConnect
//
//  Created by Mike on 12/1/17.
//

extension Command {
    public struct Device: ParticleCommunicable {
        public static var command: String = "device-id\n0\n\n"
        
        public static func parse(_ json: [AnyHashable: Any]) -> (deviceId: String, claimed: Bool)? {
            guard let id = json["id"] as? String,
                let c = json["c"] as? String,
                let cInt = Int(c) else
            { return nil }
            
            return (deviceId: id, claimed: cInt == 1)
        }
    }
}
