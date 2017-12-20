
//
//  LoaderView.swift
//  Nimble
//
//  Created by Mike on 12/1/17.
//

import UIKit

public protocol LoadingRepresentable {
    func show(_ text: String)
    func hide(_ text: String?)
    func setText(_ text: String)
}

open class ParticleLoaderView: UIView, LoadingRepresentable {
    
    // MARK: - Public
    
    public func show(_ text: String) {
        textLabel.text = text
        activityIndicator.startAnimating()
        
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        }
    }
    
    public func hide(_ text: String? = nil) {
        let fadeOut = {
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 0.0
            }) { _ in
                self.activityIndicator.stopAnimating()
            }
        }
        
        if let message = text {
            setText(message)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                fadeOut()
            }
        } else {
            fadeOut()
        }
        
    }
    
    public func setText(_ text: String) {
        UIView.animate(withDuration: 0.3, animations: {
            self.textLabel.alpha = 0.0
        }) { _ in
            self.textLabel.text = text
            UIView.animate(withDuration: 0.3, animations: {
                self.textLabel.alpha = 1.0
            })
        }
    }

    // MARK - Private
    
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    private let textLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        
        return label
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.alignment = .fill
        sv.axis = .vertical
        sv.distribution = .fillEqually
        
        return sv
    }()
    
    // MARK: - Life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.cornerRadius = 8.0
        alpha = 0.0
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
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
    
}
