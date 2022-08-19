//
//  CategoriesTableViewCell.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 14/07/2022.
//

import UIKit

class CategoriesTableViewCell: UITableViewCell {
    
    static let identifier = "CategoriesTableViewCell"
    
    private let cellMainStackView:UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        stackView.backgroundColor = .init(white: 0, alpha: 0.2)
        stackView.layer.cornerRadius = 10
        stackView.clipsToBounds = true
        return stackView
    }()
    
    private func createAccessoryView() -> UIImageView {
        let image = UIImage(systemName: "chevron.right")
        let accessory = UIImageView(frame:CGRect(x:0, y:0, width:(image?.size.width) ?? 0, height:(image?.size.height) ?? 0))
        accessory.image = image
        accessory.tintColor = Constants.Colors.primaryText
        accessory.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return accessory
    }
    
    private let descriptionStackView:UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return stackView
    }()
    
    var categoryTitle:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = Constants.Colors.primaryText
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    var categoryDescription:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = Constants.Colors.primaryText
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
        cellMainStackView.addArrangedSubviews(descriptionStackView,createAccessoryView())
        descriptionStackView.addArrangedSubviews(categoryTitle,categoryDescription)
    }
    
    private func addLayouts() {
        let cellMainStackViewConstraints = [
            cellMainStackView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 10),
            cellMainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 20),
            cellMainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -20),
            cellMainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -10),
        ]
        NSLayoutConstraint.activate(cellMainStackViewConstraints)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
