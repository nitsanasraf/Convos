//
//  LoadingViewController.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 16/07/2022.
//

import UIKit
import AgoraRtcKit

class LoadingViewController: UIViewController {
    
    private var networkManager = NetworkManger()

    private lazy var agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: KeyCenter.appID ?? "", delegate: self)
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.alignment = .center
        return stackView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = Constants.Colors.primaryText
        indicator.startAnimating()
        return indicator
    }()
    
    lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.Colors.primaryText
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byCharWrapping
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "Looking for an available room"
        label.textColor = Constants.Colors.primaryText
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byCharWrapping
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let timeAssessmentLabel: UILabel = {
        let label = UILabel()
        label.text = "(No more than 2 minutes)"
        label.textColor = Constants.Colors.primaryText
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byCharWrapping
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private lazy var cancelButton: UIButton = {
        var config = UIButton.Configuration.tinted()
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        config.title = "Cancel"
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 14,weight: .bold)
            return outgoing
        }
        config.image = UIImage(systemName: "xmark",withConfiguration: imgConfig)
        config.baseBackgroundColor = Constants.Colors.primaryText
        config.baseForegroundColor = Constants.Colors.primaryText
        config.imagePadding = 5
        config.imagePlacement = .trailing
        let btn = UIButton(configuration: config)
        btn.addTarget(self, action: #selector(cancelSearch), for: .touchUpInside)
        return btn
    }()
    
    @objc private func cancelSearch() {
        navigationController?.popViewController(animated: true)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSkeleton()
        addViews()
        addLayouts()
        RoomModel.findEmptyRoom(fromRoom: nil, networkManager: networkManager, category: categoryLabel.text, viewController: self, agoraKit: agoraKit)
    }
    
    private func configureSkeleton() {
        view.addGradient(colors: [Constants.Colors.primaryGradient, Constants.Colors.secondaryGradient])
        self.navigationItem.hidesBackButton = true
    }
    
    private func addViews() {
        view.addSubview(stackView)
        
        stackView.addArrangedSubviews(categoryLabel, activityIndicator, loadingLabel, timeAssessmentLabel, cancelButton)
    }
    
    private func addLayouts() {
        let stackViewConstraints = [
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        NSLayoutConstraint.activate(stackViewConstraints)
    }
    
}


extension LoadingViewController: AgoraRtcEngineDelegate {}
