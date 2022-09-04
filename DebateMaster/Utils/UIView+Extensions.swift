//
//  UIView+Extensions.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 06/07/2022.
//

import UIKit

extension UIView {
    
    static func spacer(size: CGFloat = 10, for layout: NSLayoutConstraint.Axis = .horizontal) -> UIView {
        let spacer = UIView()
        if layout == .horizontal {
            spacer.widthAnchor.constraint(equalToConstant: size).isActive = true
        } else {
            spacer.heightAnchor.constraint(equalToConstant: size).isActive = true
        }
        return spacer
    }
    
    func addGradient(colors: [UIColor], locations: [NSNumber] = [0, 1], startPoint: CGPoint = CGPoint(x: 0, y: 0), endPoint:CGPoint = CGPoint(x: 0, y: 1), type: CAGradientLayerType = .conic){
        let gradient = CAGradientLayer()
        gradient.frame.size = self.frame.size
        gradient.frame.origin = .zero
        gradient.colors = colors.map{ $0.cgColor }
        gradient.locations = locations
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func addBackgroundImage(with imageName: String) {
        let imageView = UIImageView(image: UIImage(named: imageName))
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.07
    }
    
}
