//
//  CategoriesViewController.swift
//  Convos
//
//  Created by Nitsan Asraf on 14/07/2022.
//

import UIKit

class CategoriesViewController: UIViewController {
    
    private var categories: [CategoryModel]?
    
    private let networkManager = NetworkManger()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = Constants.Colors.primaryText
        indicator.style = .large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        return indicator
    }()
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(CategoriesTableViewCell.self, forCellReuseIdentifier: CategoriesTableViewCell.identifier)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        return table
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.allowsSelection = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGradient(colors: [Constants.Colors.primaryGradient, Constants.Colors.secondaryGradient])
        view.addBackgroundImage(with: "main.bg")
        
        view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        guard let parent = self.parent else {return}
        KeyCenter.getKeys(viewController: parent) {
            CategoryModel.getCategories(viewController: parent) { categories in
                DispatchQueue.main.async {
                    self.categories = categories
                    self.activityIndicator.stopAnimating()
                    self.addViews()
                    self.addLayouts()
                }
            }
            
        }
        tableView.delegate = self
        tableView.dataSource = self
        
        UserModel.shared.printDetails()
    }
    
    private func addViews() {
        view.addSubview(tableView)
    }
    
    private func addLayouts() {
        let tableViewConstraints = [
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(tableViewConstraints)
    }
    
    private func openLoadingVC(withCategory category: CategoryModel?) {
        if UserModel.shared.didExceedFreeTierLimit! {
            let modalVC = PopUpViewController()
            modalVC.titleText = "Unfortunately, You exceeded your free minutes limit."
            modalVC.iconName = "popup.icon"
            modalVC.descriptionText = "In order to get unlimited minutes you'll have to become a premium member, but it'll be worth it!"
            present(modalVC, animated: true)
            tableView.allowsSelection = true
        } else {
            let vc = LoadingViewController()
            vc.category = category
            self.parent?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension CategoriesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.allowsSelection = false
        openLoadingVC(withCategory: categories?[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoriesTableViewCell.identifier, for: indexPath) as? CategoriesTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.categoryTitle.text = categories?[indexPath.row].title
        cell.categoryDescription.text = categories?[indexPath.row].description
        cell.icon.image = UIImage(named: categories?[indexPath.row].icon ?? "")
        cell.backgroundColor = .clear
        return cell
    }
    
}
