//
//  SettingsViewController.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 14/08/2022.
//

import UIKit

class SettingsViewController: UIViewController {
    
    private let sections = SettingsModel.shared.sections
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        return stackView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        
        let boldText = UserModel.shared.email ?? ""
        let boldAttrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)]
        let boldString = NSMutableAttributedString(string:boldText, attributes:boldAttrs)

        let normalText = "Currently logged in as: "
        let normalAttrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]
        let normalString = NSMutableAttributedString(string:normalText, attributes: normalAttrs)

        normalString.append(boldString)
        
        label.attributedText = normalString
        label.textColor = Constants.Colors.primaryText
        label.textAlignment = .center
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCell.identifier)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGradient(colors: [Constants.Colors.primaryGradient, Constants.Colors.secondaryGradient])
        
        tableView.delegate = self
        tableView.dataSource = self

        addViews()
        addLayouts()
        
    }
    
    private func addViews() {
        view.addSubview(stackView)
        
        stackView.addArrangedSubviews(label, tableView)
    }
    
    private func addLayouts() {
        let stackViewConstraints = [
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(stackViewConstraints)
    }
  

}

//MARK: - UITableViewDataSource & UITableViewDelegate Delegates
extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        30
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sections[indexPath.section].items[indexPath.row].function(self)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.identifier, for: indexPath) as? SettingsTableViewCell else { return UITableViewCell() }
        
        cell.selectionStyle = .none
        cell.title.text = sections[indexPath.section].items[indexPath.row].title
        cell.title.textColor = sections[indexPath.section].items[indexPath.row].color
        cell.icon.image = UIImage(systemName: sections[indexPath.section].items[indexPath.row].icon)
        cell.icon.tintColor = sections[indexPath.section].items[indexPath.row].color
        cell.backgroundColor = .clear
        return cell
    }
    
    
}
