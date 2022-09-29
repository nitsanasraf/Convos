//
//  UISwitch+Extensions.swift
//  Convos
//
//  Created by Nitsan Asraf on 29/09/2022.
//

import UIKit

extension UISwitch {

    func setSize(width: CGFloat, height: CGFloat) {

        let standardHeight: CGFloat = 31
        let standardWidth: CGFloat = 51

        let heightRatio = height / standardHeight
        let widthRatio = width / standardWidth

        transform = CGAffineTransform(scaleX: widthRatio, y: heightRatio)
    }
}
