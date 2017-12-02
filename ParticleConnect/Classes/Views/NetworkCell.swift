//
//  NetworkCell.swift
//  Nimble
//
//  Created by Mike on 12/2/17.
//

import UIKit

class NetworkCell: UITableViewCell {
    
    var network: Network? {
        didSet {
            guard let network = network else { return }
            
            textLabel?.text = network.ssid
            lockImageView.isHidden = !network.isLocked
            signalImageView.image = network.signalStrength.asset
        }
    }
    
    lazy var lockView: UIView = {
        let v = UIView()
        v.addSubview(lockImageView)
        let vMargins = v.layoutMarginsGuide
        
        lockImageView.trailingAnchor.constraint(equalTo: vMargins.trailingAnchor).isActive = true
        lockImageView.leadingAnchor.constraint(equalTo: vMargins.leadingAnchor).isActive = true
        lockImageView.topAnchor.constraint(equalTo: vMargins.topAnchor).isActive = true
        lockImageView.bottomAnchor.constraint(equalTo: vMargins.bottomAnchor).isActive = true
        lockImageView.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    lazy var lockImageView: UIImageView = {
        let image = UIImage.particleAsset(named: "lock")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .center
        imageView.isHidden = true
        return imageView
    }()
    
    lazy var signalView: UIView = {
        let v = UIView()
        v.addSubview(signalImageView)
        let vMargins = v.layoutMarginsGuide
        
        signalImageView.trailingAnchor.constraint(equalTo: vMargins.trailingAnchor).isActive = true
        signalImageView.leadingAnchor.constraint(equalTo: vMargins.leadingAnchor).isActive = true
        signalImageView.topAnchor.constraint(equalTo: vMargins.topAnchor).isActive = true
        signalImageView.bottomAnchor.constraint(equalTo: vMargins.bottomAnchor).isActive = true
        signalImageView.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    lazy var signalImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .center
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let margins = contentView.layoutMarginsGuide

        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fillEqually

        contentView.addSubview(stackView)
        
        stackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        stackView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(lockView)
        stackView.addArrangedSubview(signalView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("nope")
    }
}
