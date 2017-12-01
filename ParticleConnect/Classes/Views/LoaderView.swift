
//
//  LoaderView.swift
//  Nimble
//
//  Created by Mike on 12/1/17.
//

import UIKit

public class LoaderView: UIView {
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(activityIndicator)
        
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        layer.cornerRadius = 4.0
        alpha = 0.0
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show() {
        activityIndicator.startAnimating()
        UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) {
            self.alpha = 1.0
            }.startAnimation()
    }
    
    func hide() {
        UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) {
            self.alpha = 0.0
            self.activityIndicator.stopAnimating()
            }.startAnimation()
    }
    
    override public func layoutSubviews() {
        let margins = layoutMarginsGuide
        activityIndicator.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    }
}
