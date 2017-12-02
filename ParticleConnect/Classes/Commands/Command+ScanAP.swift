//
//  Command+ScanAP.swift
//  Nimble
//
//  Created by Mike on 12/1/17.
//

extension Command {
    struct ScanAP: ParticleCommunicable {
        static var command: String = "scan-ap\n0\n\n"
        
        internal static func parse(_ json: [AnyHashable: Any]) -> [Network]? {
            guard let scans = json["scans"] as? [[AnyHashable: Any]] else {
                return nil
            }
            
            // Generate a unique set of networks
            var networks = Set<Network>()
            for scan in scans {
                networks.insert(Network(json: scan))
            }
            
            // return an array sorted by signal strength
            return Array(networks).sorted(by: { $0.rssi > $1.rssi })
        }
    }
}
