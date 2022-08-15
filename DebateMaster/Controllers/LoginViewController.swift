//
//  LoginViewController.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 26/07/2022.
//

import UIKit
import AuthenticationServices


class LoginViewController: UIViewController {

    private let networkManager = NetworkManger()
    
    private let loginStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 50, bottom: 10, right: 50)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private let logo:UILabel = {
        let label = UILabel()
        label.text = "DebateMaster"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 40,weight: .bold)
        label.textColor = Constants.Colors.secondary
        label.textAlignment = .center
        return label
    }()
    
    private lazy var googleButton:UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Sign in with Google"
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .black
        config.image = UIImage(named: "google-icon")
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
        config.image = UIImage(named: "facebook-circle-fill")
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
    
    private let appleButton:UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Sign in with Apple"
        config.baseBackgroundColor = .black
        config.baseForegroundColor = .white
        config.image = UIImage(systemName: "applelogo")
        config.imagePadding = 10
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 16,weight: .semibold)
            return outgoing
        }
        let button = UIButton(configuration: config)
        return button
    }()
    
   
    private func saveUserOnKeyChain() {
        KeyChain.shared[Constants.KeyChain.Keys.userAuthToken] = UserModel.shared.authToken
        KeyChain.shared[Constants.KeyChain.Keys.userEmail] = UserModel.shared.email
        KeyChain.shared[Constants.KeyChain.Keys.userID] = UserModel.shared.id
        KeyChain.shared[Constants.KeyChain.Keys.userUID] = UserModel.shared.uid
    }
    
    @objc private func facebookLogin() {
        guard let authURL = URL(string:networkManager.authFacebookURL) else {return}
        
        let scheme = networkManager.schemeName
        let session = ASWebAuthenticationSession(
          url: authURL,
          callbackURLScheme: scheme) { [weak self] callbackURL, error in
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
                  
                  UserModel.shared.populateUser(token: token, email: email, id: id, uid: uid)
                  self?.saveUserOnKeyChain()
                  
                  DispatchQueue.main.async {
                      let tabVC = TabBarViewController()
                      self?.navigationController?.pushViewController(tabVC, animated: true)
                  }
              }
          }
        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = true
        session.start()
    }
    
    @objc private func googleLogin() {
        guard let authURL = URL(string: networkManager.authGoogleURL) else {return}
        
        let scheme = networkManager.schemeName
        let session = ASWebAuthenticationSession(
          url: authURL,
          callbackURLScheme: scheme) { [weak self] callbackURL, error in
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

                  UserModel.shared.populateUser(token: token, email: email, id: id, uid: uid)
                  self?.saveUserOnKeyChain()
                  
                  DispatchQueue.main.async {
                      let tabVC = TabBarViewController()
                      self?.navigationController?.pushViewController(tabVC, animated: true)
                  }
              }
          }
        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = true
        session.start()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserModel.shared.isUserLoggedIn() {
            self.navigationController?.pushViewController(TabBarViewController(), animated: false)
        }
        view.backgroundColor = Constants.Colors.primary
        addViews()
        addLayouts()
    }
    

    private func addViews() {
        view.addSubview(loginStackView)
        
        loginStackView.addArrangedSubview(logo)
        loginStackView.addArrangedSubview(facebookButton)
        loginStackView.addArrangedSubview(googleButton)
        loginStackView.addArrangedSubview(appleButton)
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
