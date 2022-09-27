//
//  SettingsModel.swift
//  Convos
//
//  Created by Nitsan Asraf on 16/08/2022.
//

import UIKit

protocol SettingsProtocol: AnyObject {
    func openNotification()
    func openDataCollection()
    func openNetworking()
    func openPrivacy()
    func openTerms()
    func logout()
    func deleteUser()
    func premium()
}

class SettingsModel {
    
    weak var delegate: SettingsProtocol?
    
    struct Section {
        let title: String
        let items: [Item]
    }
    
    struct Item {
        let title: String
        let color: UIColor
        let icon: String
        let function: () -> ()
    }
    
    lazy var sections = [
        Section(title: "Privacy" ,items: [
            Item(title: "Notifications", color: Constants.Colors.primaryText, icon: "bell.fill") {
                self.delegate?.openNotification()
            },
            Item(title: "Data collection", color: Constants.Colors.primaryText, icon: "antenna.radiowaves.left.and.right") {
                self.delegate?.openDataCollection()
            },
            Item(title: "Networking", color: Constants.Colors.primaryText, icon: "network") {
                self.delegate?.openNetworking()
            },
        ]),
        
        Section(title: "Policies" ,items: [
            Item(title: "Privacy policy", color: Constants.Colors.primaryText, icon: "checkerboard.shield") {
                self.delegate?.openPrivacy()
            },
            Item(title: "Terms and conditions", color: Constants.Colors.primaryText, icon: "newspaper") {
                self.delegate?.openTerms()
            },
        ]),
        
        Section(title: "Account" ,items: [
            Item(title: "Logout", color: Constants.Colors.primaryText, icon: "arrow.uturn.left") {
                self.delegate?.logout()
            },
            Item(title: "Delete account", color: .systemRed, icon: "trash.fill") {
                self.delegate?.deleteUser()
            }
        ]),
        
        Section(title: "Premium" ,items: [
            Item(title: "Get a premium membership", color: .systemYellow, icon: "crown.fill") {
                self.delegate?.premium()
            },
        ]),
    ]
}
