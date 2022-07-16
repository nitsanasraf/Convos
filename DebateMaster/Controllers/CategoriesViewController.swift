//
//  CategoriesViewController.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 14/07/2022.
//

import UIKit

class CategoriesViewController: UIViewController {
    
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
        
    }
    
    private func configureSkeleton() {
        view.backgroundColor = .systemPink
        title = "All Categories"
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
