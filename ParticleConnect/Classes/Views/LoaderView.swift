
//
//  LoaderView.swift
//  Nimble
//
//  Created by Mike on 12/1/17.
//

import UIKit

internal class LoaderView: UIView {
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    let textLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        
        return label
    }()
    
    let stackView: UIStackView = {
        let sv = UIStackView()
        sv.alignment = .fill
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.spacing = 8.0
        
        return sv
    }()
    
    // MARK: - Life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        layer.cornerRadius = 8.0
        alpha = 0.0
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setup() {
        setupStackView()
        setupActivityIndicator()
        setupTextLabel()
    }
    
    private func setupStackView() {
        let viewMargins = layoutMarginsGuide
        
        addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: viewMargins.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: viewMargins.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: viewMargins.topAnchor, constant: 8).isActive = true
        stackView.bottomAnchor.constraint(equalTo: viewMargins.bottomAnchor).isActive = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupActivityIndicator() {
        stackView.addArrangedSubview(activityIndicator)
    }
    
    private func setupTextLabel() {
        stackView.addArrangedSubview(textLabel)
        
        let stackViewMargins = stackView.layoutMarginsGuide
        
        textLabel.leadingAnchor.constraint(equalTo: stackViewMargins.leadingAnchor).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: stackViewMargins.trailingAnchor).isActive = true
        textLabel.widthAnchor.constraint(equalToConstant: 160).isActive = true
        textLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func show(_ initialText: String) {
        textLabel.text = initialText
        activityIndicator.startAnimating()
            
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.0
        }) { _ in
            self.activityIndicator.stopAnimating()
        }
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
