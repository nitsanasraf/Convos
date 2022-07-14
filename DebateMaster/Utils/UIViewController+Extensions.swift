//
//  UIViewController+Extensions.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 14/07/2022.
//

import UIKit

extension UIViewController {
    func embed(_ viewController:UIViewController, inView view:UIView){
        viewController.willMove(toParent: self)
        viewController.view.frame = view.bounds
        view.addSubview(viewController.view)
        self.addChild(viewController)
        viewController.didMove(toParent: self)
    }
}
