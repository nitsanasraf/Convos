//
//  CategoriesViewController.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 14/07/2022.
//

import UIKit

class CategoriesViewController: UIViewController {
    private let networkManager = NetworkManger()
    
    private let tableView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSkeleton()
        addViews()
        addLayouts()
        UserModel.shared.printDetails()
    }
    
    private func configureSkeleton() {
        view.backgroundColor = .systemPink
        title = "All Categories"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.backward.square"), style: .plain, target: self, action: #selector(logout))
    }
    
    @objc private func logout() {
        guard let url = URL(string: "http://localhost:8080/users/logout") else {return}
        let task = URLSession.shared.dataTask(with: url) { [weak self] (_, response, error) in
            if let error = error {
                print("Error fetching: \(error)")
            } else {
                KeyChain.shared.deleteAll()
                UserModel.shared.resetUser()
                DispatchQueue.main.async {
                    let loginVC = LoginViewController()
                    loginVC.modalPresentationStyle = .fullScreen
                    self?.present(loginVC, animated: true)
                }
            }
        }
        task.resume()
    
    }
    
    private func addViews() {
        view.addSubview(tableView)
        embed(CategoriesTableViewController(), inView: tableView)
    }
    
    private func addLayouts() {
        let tableViewConstraints = [
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(tableViewConstraints)
    }
}
