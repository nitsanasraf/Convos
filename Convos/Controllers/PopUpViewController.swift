//
//  PopUpViewController.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 10/09/2022.
//

import UIKit
import StoreKit

class PopUpViewController: UIViewController {

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.spacing = 20
        return stackView
    }()
    
    private let icon :UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "popup.icon"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        imageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return imageView
    }()
    
    private let titleLabel :UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = "Unfortunately, You exceeded your free minutes limit."
        label.textColor = Constants.Colors.secondaryText
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textAlignment = .center
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private let descriptionLabel :UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = "In order to get unlimited minutes you'll have to become a premium member, but it'll be worth it!"
        label.textColor = Constants.Colors.secondaryText
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .center
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private func createPros(text: String) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        let icon = UIImageView(image: UIImage(systemName: "checkmark.circle.fill", withConfiguration: config))
        icon.tintColor = Constants.Colors.secondaryText
        icon.contentMode = .scaleAspectFit
        icon.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let label = UILabel()
        label.text = text
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = Constants.Colors.secondaryText
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        stackView.addArrangedSubviews(icon,label)
        stackView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return stackView
    }
    
    private let buyButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Subscribe now for 9.99$ per month"
        config.baseBackgroundColor = Constants.Colors.primaryGradient
        config.baseForegroundColor = Constants.Colors.primaryText
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 14,weight: .bold)
            return outgoing
        }
        let button = UIButton(configuration: config)
        button.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Maybe later"
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .black
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 14,weight: .bold)
            return outgoing
        }
        let button = UIButton(configuration: config)
        button.setContentHuggingPriority(.defaultHigh, for: .vertical)
        button.addTarget(self, action: #selector(dismissPopUp), for: .touchUpInside)
        return button
    }()
    
    @objc private func dismissPopUp() {
        dismiss(animated: true)
    }
    
    private let spacer = UIButton()
    
    private func animateIcon() {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 2.0
        pulseAnimation.fromValue = 0.8
        pulseAnimation.toValue = 1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        icon.layer.add(pulseAnimation, forKey: nil)
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.duration = 2.0
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = Float.pi
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        rotationAnimation.autoreverses = true
        rotationAnimation.repeatCount = .greatestFiniteMagnitude
        icon.layer.add(rotationAnimation, forKey: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGradient(colors: [Constants.Colors.tertiaryGradient, Constants.Colors.quaternaryGradient])
        view.addBackgroundImage(with: "main.bg")
        addViews()
        addLayouts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIcon()
    }
    
    private func addViews() {
        view.addSubview(stackView)
        stackView.addArrangedSubviews(icon, titleLabel, descriptionLabel,
                                      createPros(text: "Unlimited minutes"),
                                      createPros(text: "Premium tag"),
                                      createPros(text: "Golden frame"),
                                      createPros(text: "Suggest new topics"),
                                      buyButton, cancelButton, spacer)
    }
    
    private func addLayouts() {
        let stackViewConstraints = [
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ]
        
        NSLayoutConstraint.activate(stackViewConstraints)
    }
    
    override func updateViewConstraints() {
        self.view.frame.size.height = UIScreen.main.bounds.height - 150
        self.view.frame.origin.y = 150
        self.view.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
        super.updateViewConstraints()
    }
    
}


