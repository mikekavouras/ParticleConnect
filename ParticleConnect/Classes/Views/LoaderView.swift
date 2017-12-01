
//
//  LoaderView.swift
//  Nimble
//
//  Created by Mike on 12/1/17.
//

import UIKit

class LoaderView: UIView {
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    let textLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        layer.cornerRadius = 8.0
        alpha = 0.0
        
        addSubview(activityIndicator)
        addSubview(textLabel)
        
        textLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        textLabel.textColor = .white
        textLabel.textAlignment = .center
        
        let viewMargins = layoutMarginsGuide
        
        activityIndicator.leadingAnchor.constraint(equalTo: viewMargins.leadingAnchor).isActive = true
        activityIndicator.trailingAnchor.constraint(equalTo: viewMargins.trailingAnchor).isActive = true
        activityIndicator.topAnchor.constraint(equalTo: viewMargins.topAnchor, constant: 8).isActive = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        let activityIndicatorMargins = activityIndicator.layoutMarginsGuide
        
        textLabel.topAnchor.constraint(equalTo: activityIndicatorMargins.bottomAnchor, constant: 16).isActive = true
        textLabel.leadingAnchor.constraint(equalTo: viewMargins.leadingAnchor).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: viewMargins.trailingAnchor).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: viewMargins.bottomAnchor).isActive = true
        textLabel.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        textLabel.widthAnchor.constraint(equalToConstant: 160).isActive = true
        textLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(_ initialText: String) {
        textLabel.text = initialText
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
    
    func setText(_ text: String) {
        UIView.animate(withDuration: 0.3, animations: {
            self.textLabel.alpha = 0.0
        }) { _ in
            self.textLabel.text = text
            UIView.animate(withDuration: 0.3, animations: {
                self.textLabel.alpha = 1.0
            })
        }
    }
}

