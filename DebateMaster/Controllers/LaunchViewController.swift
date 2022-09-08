//
//  LaunchViewController.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 30/08/2022.
//

import UIKit
import PocketSVG

class LaunchViewController: UIViewController {
    
    private let logo: SVGImageView = {
        let url = Bundle.main.url(forResource: "logo", withExtension: "svg")!
        let svgImageView = SVGImageView.init(contentsOf: url)
        svgImageView.contentMode = .scaleAspectFit
        svgImageView.translatesAutoresizingMaskIntoConstraints = false
        svgImageView.layer.shouldRasterize = false
        svgImageView.fillColor = Constants.Colors.primaryGradient
        return svgImageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addViews()
        addLayouts()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else {return}
            self.animate()
        }
    }
    
    
    private func addViews() {
        view.addSubview(logo)
    }
    
    private func addLayouts() {
        let logoConstraints = [
            logo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logo.widthAnchor.constraint(equalToConstant: 200.0),
            logo.heightAnchor.constraint(equalToConstant: 200.0),
        ]
        NSLayoutConstraint.activate(logoConstraints)
    }
    
    
    private func animate() {
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseIn) {
            self.logo.transform = CGAffineTransform(scaleX: 20, y: 20)
        } completion: { [weak self] isFinished in
            if isFinished {
                let loginVC = UINavigationController(rootViewController: LoginViewController())
                loginVC.modalPresentationStyle = .fullScreen
                loginVC.modalTransitionStyle = .crossDissolve
                self?.present(loginVC, animated: true)
            }
        }
    }
    
}
