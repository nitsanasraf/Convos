//
//  SettingsViewController.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 14/08/2022.
//

import UIKit

class SettingsViewController: UIViewController {
    
    private let sections = SettingsModel.shared.sections
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCell.identifier)
        table.backgroundColor = Constants.Colors.primary
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        addViews()
        addLayouts()
        
    }
    
    private func addViews() {
        view.addSubview(tableView)
    }
    
    private func addLayouts() {
        let tableViewConstraints = [
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

        ]
        NSLayoutConstraint.activate(tableViewConstraints)
    }
  

}


extension SettingsViewController: UITableViewDelegate {}

extension SettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sections[indexPath.section].items[indexPath.row].function()
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
        cell.icon.image = UIImage(systemName: sections[indexPath.section].items[indexPath.row].icon)
        return cell
    }
    
    
}
