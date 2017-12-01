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
            let networks = scans.map { Network(json: $0) }
            return networks.sorted(by: { $0.rssi > $1.rssi })
        }
    }
}
