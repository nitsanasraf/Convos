//
//  PopUpViewController.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 10/09/2022.
//

import UIKit

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
        imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        imageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return imageView
    }()
    
    private let titleLabel :UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = "Unfortunately, You exceeded your free minutes limit."
        label.textColor = Constants.Colors.primaryText
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
        label.textColor = Constants.Colors.primaryText
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
        icon.tintColor = Constants.Colors.primaryText
        icon.contentMode = .scaleAspectFit
        icon.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let label = UILabel()
        label.text = text
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = Constants.Colors.primaryText
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        stackView.addArrangedSubviews(icon,label)
        stackView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return stackView
    }
    
    private let buyButton: UIButton = {
        var config = UIButton.Configuration.tinted()
        config.title = "Subscribe now for 9.99$ per month"
        config.baseBackgroundColor = .systemYellow
        config.baseForegroundColor = .systemYellow
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
        var config = UIButton.Configuration.tinted()
        config.title = "Not interested."
        config.baseBackgroundColor = Constants.Colors.primaryText
        config.baseForegroundColor = Constants.Colors.primaryText
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
    
    @objc
    private func dismissPopUp() {
        dismiss(animated: true)
    }
    
    private let spacer = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGradient(colors: [Constants.Colors.primaryGradient, Constants.Colors.secondaryGradient])
        view.addBackgroundImage(with: "main.bg")
        addViews()
        addLayouts()
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
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]
        
        NSLayoutConstraint.activate(stackViewConstraints)
    }
    

}
