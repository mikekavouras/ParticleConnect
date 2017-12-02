//
//  UIImage+ParticleConnect.swift
//  Nimble
//
//  Created by Mike on 12/2/17.
//

import UIKit

extension UIImage {
    static func particleAsset(named name: String) -> UIImage {
        let frameworkBundle = Bundle(for: NetworkCell.self)
        let bundleURL = frameworkBundle.url(forResource: "ParticleConnect", withExtension: "bundle")!
        let resourceBundle = Bundle(url: bundleURL)
        return UIImage(named: name, in: resourceBundle, compatibleWith: nil)!
    }
}
