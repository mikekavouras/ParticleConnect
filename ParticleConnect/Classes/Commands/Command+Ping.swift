//
//  Command+Ping.swift
//  Nimble
//
//  Created by Mike on 12/1/17.
//

extension Command {
    public struct Ping: ParticleCommunicable {
        public static var command: String = "ping"
        
        public static func parse(_ json: [AnyHashable: Any]) -> String? {
            return nil
        }
    }
}
