//
//  CustomLoaderView.swift
//  ParticleConnect_Example
//
//  Created by Mike on 12/4/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import ParticleConnect

class SlackLoaderView: UIView, LoadingRepresentable {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(blueView)
        addSubview(greenView)
        addSubview(redView)
        addSubview(yellowView)
        
        heightAnchor.constraint(equalToConstant: frameWidth).isActive = true
        widthAnchor.constraint(equalToConstant: frameWidth).isActive = true
        
        setupViews()
        
        let timer = Timer(timeInterval: 0.1, repeats: false) { _ in
            self.animate()
        }
        RunLoop.current.add(timer, forMode: .commonModes)
        
        transform = transform.rotated(by: -0.2)
        
        backgroundColor = UIColor.white.withAlphaComponent(0.7)
        layer.cornerRadius = 8.0
        alpha = 0.0
    }
    
    func show(_ text: String) {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        }
    }
    
    func hide(_ text: String? = nil) {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0.0
        }
    }
    
    func setText(_ text: String) {}
    
    private func animate() {
        let thirdAnimation = UIViewPropertyAnimator(duration: animationDuration, curve: .easeInOut) {
            self.blueView.frame = .init(x: self.frameWidth - self.padding, y: self.padding, width: self.lineWidth, height: self.lineWidth)
            self.greenView.frame = .init(x: self.padding, y: self.lineWidth, width: self.lineWidth, height: self.lineWidth)
            self.redView.frame = .init(x: self.lineWidth, y: self.frameWidth - self.padding - self.lineWidth, width: self.lineWidth, height: self.lineWidth)
            self.yellowView.frame = .init(x: self.frameWidth - self.padding - self.lineWidth, y: self.frameWidth - self.padding, width: self.lineWidth, height: self.lineWidth)
        }
        
        thirdAnimation.addCompletion { _ in
            self.animate()
        }
        
        let secondAnimation = UIViewPropertyAnimator(duration: animationDuration, curve: .easeInOut) {
            self.blueView.frame = .init(x: self.lineWidth, y: self.padding, width: self.lineWidth, height: self.lineWidth)
            self.greenView.frame = .init(x: self.padding, y: self.frameWidth - self.padding, width: self.lineWidth, height: self.lineWidth)
            self.redView.frame = .init(x: self.frameWidth - self.padding, y: self.frameWidth - self.padding - self.lineWidth, width: self.lineWidth, height: self.lineWidth)
            self.yellowView.frame = .init(x: self.frameWidth - self.padding - self.lineWidth, y: self.lineWidth, width: self.lineWidth, height: self.lineWidth)
        }
        
        secondAnimation.addCompletion { _  in
            thirdAnimation.startAnimation()
        }
        
        let firstAnimation = UIViewPropertyAnimator(duration: animationDuration, curve: .easeInOut) {
            self.blueView.frame = .init(x: self.lineWidth, y: self.padding, width: self.frameWidth - self.padding, height: self.lineWidth)
            self.greenView.frame = .init(x: self.padding, y: self.lineWidth, width: self.lineWidth, height: self.frameWidth - self.padding)
            self.redView.frame = .init(x: self.lineWidth, y: self.frameWidth - self.padding - self.lineWidth, width: self.frameWidth - self.padding, height: self.lineWidth)
            self.yellowView.frame = .init(x: self.frameWidth - self.padding - self.lineWidth, y: self.lineWidth, width: self.lineWidth, height: self.frameWidth - self.padding)
        }
        firstAnimation.addCompletion { _ in
            secondAnimation.startAnimation()
        }
        
        firstAnimation.startAnimation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("nah")
    }
    
    private let animationDuration = 0.7
    private let frameWidth: CGFloat = 80.0
    private let padding: CGFloat = 20
    private let lineWidth: CGFloat = 10
    
    private func setupViews() {
        blueView.frame = .init(x: frameWidth - padding, y: padding, width: lineWidth, height: lineWidth)
        greenView.frame = .init(x: padding, y: lineWidth, width: lineWidth, height: lineWidth)
        redView.frame = .init(x: lineWidth, y: frameWidth - padding - lineWidth, width: lineWidth, height: lineWidth)
        yellowView.frame = .init(x: frameWidth - padding - lineWidth, y: frameWidth - padding, width: lineWidth, height: lineWidth)
    }
    
    private let blueView: UIView = {
        let v = UIView(frame: .zero)
        v.layer.cornerRadius = 5.0
        v.backgroundColor = UIColor(red: 110/255.0, green: 202/255.0, blue: 220/255.0, alpha: 0.9)
        return v
    }()
    
    private let greenView: UIView = {
        let v = UIView(frame: .zero)
        v.layer.cornerRadius = 5.0
        v.backgroundColor = UIColor(red: 62/255.0, green: 185/255.0, blue: 145/255.0, alpha: 0.9)
        return v
    }()
    
    private let redView: UIView = {
        let v = UIView(frame: .zero)
        v.layer.cornerRadius = 5.0
        v.backgroundColor = UIColor(red: 224/255.0, green: 21/255.0, blue: 99/255.0, alpha: 0.9)
        return v
    }()
    
    private let yellowView: UIView = {
        let v = UIView(frame: .zero)
        v.layer.cornerRadius = 5.0
        v.backgroundColor = UIColor(red: 233/255.0, green: 168/255.0, blue: 32/255.0, alpha: 0.9)
        return v
    }()
    
}
