//
//  LoginViewController.swift
//  Convos
//
//  Created by Nitsan Asraf on 26/07/2022.
//

import UIKit
import AuthenticationServices
import PocketSVG

class LoginViewController: UIViewController {
    
    private let networkManager = NetworkManger()
    
    private func saveUserOnKeyChain() {
        guard let seconds = UserModel.shared.secondsSpent else {return}
        KeyChain.shared[Constants.KeyChain.Keys.userAuthToken] = UserModel.shared.authToken
        KeyChain.shared[Constants.KeyChain.Keys.userEmail] = UserModel.shared.email
        KeyChain.shared[Constants.KeyChain.Keys.userID] = UserModel.shared.id
        KeyChain.shared[Constants.KeyChain.Keys.userUID] = UserModel.shared.uid
        KeyChain.shared[Constants.KeyChain.Keys.userSeconds] = String(seconds)
    }
    
    private let loginStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 50, bottom: 10, right: 50)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private let logo: SVGImageView = {
        let url = Bundle.main.url(forResource: "logo", withExtension: "svg")!
        let svgImageView = SVGImageView.init(contentsOf: url)
        svgImageView.contentMode = .scaleAspectFit
        svgImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        svgImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        svgImageView.translatesAutoresizingMaskIntoConstraints = false
        svgImageView.layer.shouldRasterize = false
        svgImageView.fillColor = .white
        return svgImageView
    }()
    
    private let logoLabel: UILabel = {
        let label = UILabel()
        label.text = "Convos"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 40,weight: .bold)
        label.textColor = Constants.Colors.primaryText
        label.textAlignment = .center
        return label
    }()
    
    private lazy var googleButton:UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Sign in with Google"
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .black
        config.image = UIImage(named: "google.icon")
        config.imagePadding = 10
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 16,weight: .semibold)
            return outgoing
        }
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(googleLogin), for: .touchUpInside)
        return button
    }()
    
    private lazy var facebookButton:UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Sign in with Facebook"
        config.baseBackgroundColor = UIColor(red: 0.26, green: 0.40, blue: 0.70, alpha: 1.00)
        config.baseForegroundColor = .white
        config.image = UIImage(named: "facebook.icon")
        config.imagePadding = 10
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 16,weight: .semibold)
            return outgoing
        }
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(facebookLogin), for: .touchUpInside)
        return button
    }()
    
    @objc private func googleLogin(_ sender: UIButton) {
        sender.isEnabled = false
        guard let authURL = URL(string: networkManager.authGoogleURL) else {return}

        let scheme = networkManager.schemeName
        let session = ASWebAuthenticationSession(
          url: authURL,
          callbackURLScheme: scheme) { [weak self] (callbackURL, error) in
              guard let self = self else {return}
              sender.isEnabled = true
              if let error = error {
                  print("Auth Error: \(error)")
              } else {
                  guard let callbackURL = callbackURL else {return}
                  let queryItems =
                  URLComponents(string: callbackURL.absoluteString)?.queryItems
                  
                  let token = queryItems?.first { $0.name == "token" }?.value
                  let email = queryItems?.first { $0.name == "email" }?.value
                  let id = queryItems?.first { $0.name == "id" }?.value
                  let uid = queryItems?.first { $0.name == "uid" }?.value
                  let secondsSpent = queryItems?.first { $0.name == "seconds" }?.value

                  guard let seconds = Int(secondsSpent ?? "") else {return}

                  UserModel.shared.populateUser(token: token, email: email, id: id, uid: uid, secondsSpent: seconds)
                  self.saveUserOnKeyChain()
                  
                  DispatchQueue.main.async {
                      let tabVC = TabBarViewController()
                      self.navigationController?.pushViewController(tabVC, animated: true)
                  }
              }
          }
        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = true
        session.start()
    }
    
    @objc private func facebookLogin(_ sender: UIButton) {
        sender.isEnabled = false
        guard let authURL = URL(string:networkManager.authFacebookURL) else {return}
        
        let scheme = networkManager.schemeName
        let session = ASWebAuthenticationSession(
          url: authURL,
          callbackURLScheme: scheme) { [weak self] (callbackURL, error) in
              guard let self = self else {return}
              sender.isEnabled = true
              if let error = error {
                  print("Auth Error: \(error)")
              } else {
                  guard let callbackURL = callbackURL else {return}
                  let queryItems =
                  URLComponents(string: callbackURL.absoluteString)?.queryItems
                  
                  let token = queryItems?.first { $0.name == "token" }?.value
                  let email = queryItems?.first { $0.name == "email" }?.value
                  let id = queryItems?.first { $0.name == "id" }?.value
                  let uid = queryItems?.first { $0.name == "uid" }?.value
                  let secondsSpent = queryItems?.first { $0.name == "seconds" }?.value
                  
                  guard let seconds = Int(secondsSpent ?? "") else {return}

                  UserModel.shared.populateUser(token: token, email: email, id: id, uid: uid, secondsSpent: seconds)
                  self.saveUserOnKeyChain()
                  
                  DispatchQueue.main.async {
                      let tabVC = TabBarViewController()
                      self.navigationController?.pushViewController(tabVC, animated: true)
                  }
              }
          }
        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = true
        session.start()
    }
    
    @objc private func appleLogin(_ sender: UIButton) {
        sender.isEnabled = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserModel.shared.isUserLoggedIn() {
            self.navigationController?.pushViewController(TabBarViewController(), animated: false)
        }
        
        view.addGradient(colors: [Constants.Colors.primaryGradient, Constants.Colors.secondaryGradient])
        view.addBackgroundImage(with: "main.bg")
        
        addViews()
        addLayouts()
    }
    

    private func addViews() {
        view.addSubview(loginStackView)
        
        loginStackView.addArrangedSubviews(logo, logoLabel, facebookButton, googleButton)
    }
    
    private func addLayouts() {
        let loginStackViewConstraints = [
            loginStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loginStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loginStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ]
        
        NSLayoutConstraint.activate(loginStackViewConstraints)
    }
}


extension LoginViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(
        for session: ASWebAuthenticationSession
    ) -> ASPresentationAnchor {
        guard let window = view.window else {
            fatalError("No window found in view")
        }
        return window
    }
}
