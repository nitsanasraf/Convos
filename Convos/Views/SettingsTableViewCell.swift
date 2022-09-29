//
//  SettingsTableViewCell.swift
//  Convos
//
//  Created by Nitsan Asraf on 16/08/2022.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    static let identifier = "SettingsTableViewCell"
    
    private var switchState: Bool {
        get {
            let state = UserDefaults.standard.object(forKey: "switchState") as? Bool
            guard let state = state else { return true }
            return state
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "switchState")
        }
    }
    
    lazy var isSwitch = false {
        willSet {
            self.icon.removeFromSuperview()
            self.cellMainStackView.addArrangedSubview(switchButton)
        }
    }
    
    private lazy var switchButton: UISwitch = {
        let switchButton = UISwitch()
        let offColor: UIColor = .systemGray4
        switchButton.isOn = switchState
        switchButton.tintColor = offColor
        switchButton.layer.cornerRadius = switchButton.frame.height / 2.0
        switchButton.backgroundColor = offColor
        switchButton.clipsToBounds = true
        switchButton.setSize(width: 51/1.1, height: 31/1.1)
        switchButton.addTarget(self, action: #selector(switchStateChanged), for: .valueChanged)
        return switchButton
    }()
    
    @objc private func switchStateChanged(_ sender:UISwitch) {
        if sender.isOn {
            switchState = true
            //continue notifications
        } else {
            switchState = false
            //stop notifications
        }
    }
    
    private let cellMainStackView:UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        stackView.backgroundColor = .init(white: 0, alpha: 0.1)
        stackView.layer.cornerRadius = 10
        stackView.clipsToBounds = true
        return stackView
    }()
        
    var icon: UIImageView = {
        let image = UIImage(systemName: "chevron.right")
        let accessory = UIImageView(frame:CGRect(x:0, y:0, width:(image?.size.width) ?? 0, height:(image?.size.height) ?? 0))
        accessory.image = image
        accessory.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return accessory
    }()
    
    var title:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addViews()
        addLayouts()
    }
    
    private func addViews() {
        contentView.addSubview(cellMainStackView)
        
        cellMainStackView.addArrangedSubviews(title, icon)
    }
    
    private func addLayouts() {
        let cellMainStackViewConstraints = [
            cellMainStackView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 5),
            cellMainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellMainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellMainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
        ]
        
        NSLayoutConstraint.activate(cellMainStackViewConstraints)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
