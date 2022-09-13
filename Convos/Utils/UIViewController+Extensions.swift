//
//  UIViewController+Extensions.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 14/07/2022.
//

import UIKit

extension UIViewController {
    
    func showToast(message: String, icon iconName: String, alertColor color: UIColor) {
        let container = UIStackView()
        container.axis = .horizontal
        container.translatesAutoresizingMaskIntoConstraints = false
        container.spacing = 0
        container.alpha = 0.0
        container.layer.cornerRadius = 10
        container.clipsToBounds  =  true
        container.backgroundColor = .black.withAlphaComponent(0.6)
        container.alignment = .center

        let paddingSize = 15.0
        let iconView = UIStackView()
        iconView.layoutMargins = UIEdgeInsets(top: paddingSize, left: paddingSize, bottom: paddingSize, right: paddingSize)
        iconView.isLayoutMarginsRelativeArrangement = true
        iconView.backgroundColor = color
        
        let textView = UIStackView()
        textView.layoutMargins = UIEdgeInsets(top: 0, left: paddingSize, bottom: 0, right: paddingSize)
        textView.isLayoutMarginsRelativeArrangement = true
        
        let icon = UIImageView(image: UIImage(systemName: iconName))
        
        let toastLabel = UILabel()
        toastLabel.textColor = .white
        toastLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        toastLabel.textAlignment = .left
        toastLabel.text = message
        toastLabel.numberOfLines = 0
        toastLabel.lineBreakMode = .byWordWrapping
        
        self.view.addSubview(container)
        container.addArrangedSubviews(iconView, textView)
        iconView.addArrangedSubview(icon)
        textView.addArrangedSubview(toastLabel)
        
        container.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        container.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        container.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        
        let bottomIn = CGAffineTransform(translationX: 0, y: -30)
        let bottomOut = CGAffineTransform(translationX: 0, y: 0)
        
        UIView.animate(withDuration: 0.7, delay: 0.1, options: .curveEaseInOut, animations: {
            container.alpha = 1.0
            container.transform = bottomIn
        }, completion: { _ in
            UIView.animate(withDuration: 0.7, delay: 4.0, options: .curveEaseInOut) {
                container.alpha = 0.0
                container.transform = bottomOut
            } completion: { _ in
                container.removeFromSuperview()
            }

        })
    }
}
