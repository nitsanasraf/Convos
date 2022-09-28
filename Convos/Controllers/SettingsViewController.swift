//
//  SettingsViewController.swift
//  Convos
//
//  Created by Nitsan Asraf on 14/08/2022.
//

import UIKit

class SettingsViewController: UIViewController {
    
    private let settings = SettingsModel()
    
    private let networkManager = NetworkManger()
    
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
        table.showsVerticalScrollIndicator = false
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGradient(colors: [Constants.Colors.primaryGradient, Constants.Colors.secondaryGradient])
        view.addBackgroundImage(with: "main.bg")
        settings.delegate = self
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
        settings.sections.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        settings.sections[indexPath.section].items[indexPath.row].function()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        settings.sections[section].title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.identifier, for: indexPath) as? SettingsTableViewCell else { return UITableViewCell() }
        
        cell.selectionStyle = .none
        cell.title.text = settings.sections[indexPath.section].items[indexPath.row].title
        cell.title.textColor = settings.sections[indexPath.section].items[indexPath.row].color
        cell.icon.image = UIImage(systemName: settings.sections[indexPath.section].items[indexPath.row].icon)
        cell.icon.tintColor = settings.sections[indexPath.section].items[indexPath.row].color
        cell.backgroundColor = .clear
        return cell
    }
}

extension SettingsViewController: SettingsProtocol {
    func openNotification() {
        
    }
    
    func openDataCollection() {
        print("Data collection")
    }
    
    func openNetworking() {
        print("Networking")
    }
    
    func openPrivacy() {
        let vc = ContentViewController()
        if let path = Bundle.main.path(forResource: "PrivacyPolicy", ofType: "txt") {
            do {
                let privacyPolicy = try String(contentsOfFile: path, encoding: .utf8)
                vc.content = privacyPolicy
            } catch {
                print("Error reading file PrivacyPolicy.txt: \(error)")
            }
        }
        vc.title = "Privacy Policy"
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    func openTerms() {
        print("Terms")
    }
    
    func logout() {
        let alert = UIAlertController(title: "Are you sure you want to log out?", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "YES", style: .destructive) { [weak self] alert in
            guard let self = self,
                  let parentVC = self.parent else {return}
            UserModel.shared.logout()
            parentVC.navigationController?.popToRootViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteUser() {
        let alert = UIAlertController(title: "Are you sure you want to delete your account?", message: nil, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "DELETE", style: .destructive) { [weak self] alert in
            guard let self = self,
                  let userID = UserModel.shared.id,
                  let parentVC = self.parent else { return }
            self.networkManager.sendData(object: userID, url: self.networkManager.deletedUserURL, httpMethod: Constants.HttpMethods.POST.rawValue) { [weak self] (data, statusCode) in
                guard let self = self else {return}
                self.networkManager.handleErrors(statusCode: statusCode, viewController: parentVC)
                if statusCode >= 200 && statusCode <= 299 {
                    DispatchQueue.main.async {
                        UserModel.shared.logout()
                        parentVC.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
        })
        alert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func getPremium() {
        let modalVC = PopUpViewController()
        modalVC.iconName = "popup.icon2"
        modalVC.titleText = "Subscribe for a premium membership"
        modalVC.descriptionText = "With becoming a premium member you'll recieve many privileges, such as:"
        self.present(modalVC, animated: true)
    }
    
    
}
