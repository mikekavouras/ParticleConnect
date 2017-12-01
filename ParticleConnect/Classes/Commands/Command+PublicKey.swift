//
//  Command+PublicKey.swift
//  Nimble
//
//  Created by Mike on 12/1/17.
//

extension Command {
    public struct PublicKey: ParticleCommunicable {
        public static var command: String = "public-key\n0\n\n"
        
        public static func parse(_ json: [AnyHashable: Any]) -> Int? {
            guard let key = json["b"] as? String,
                let r = json["r"] as? Int else
            { return nil }
            
            guard let pubKey = try! Security.decode(fromHexString: key) else { return nil }
            do {
                try Security.setPublicKey(data: pubKey)
            } catch { return nil }
            
            return r
        }
    }
}
