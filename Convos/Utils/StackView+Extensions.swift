//
//  StackView+Extensions.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 17/08/2022.
//

import UIKit

extension UIStackView {
    func addArrangedSubviews(_ views:UIView...) {
        for view in views {
            self.addArrangedSubview(view)
        }
    }
}
