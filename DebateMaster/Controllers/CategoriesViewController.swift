//
//  CategoriesViewController.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 14/07/2022.
//

import UIKit

class CategoriesViewController: UIViewController {
   
    private let categories = [
        ["title":"History 📖","desc":"Discuss history and newest conventions in history."],
        ["title":"Politics 📋","desc":"Discuss politics and newest conventions in politics."],
        ["title":"Economics 📉","desc":"Discuss economics and newest conventions in economy."],
        ["title":"Law 📜","desc":"Discuss law and newest conventions in law."],
        ["title":"Technology 🤖","desc":"Discuss technology and newest conventions in technology."],
        ["title":"Science 🪐","desc":"Discuss science and newest conventions in science."],
    ]
    
    private let networkManager = NetworkManger()
        
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(CategoriesTableViewCell.self, forCellReuseIdentifier: CategoriesTableViewCell.identifier)
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
    
    private func openLoadingVC(withCategory category:String) {
        let vc = LoadingViewController()
        vc.categoryLabel.text = category
        self.parent?.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension CategoriesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openLoadingVC(withCategory: categories[indexPath.row]["title"]!)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoriesTableViewCell.identifier, for: indexPath) as? CategoriesTableViewCell else { return UITableViewCell() }
        
        cell.selectionStyle = .none
        cell.categoryTitle.text = categories[indexPath.row]["title"]!
        cell.categoryDescription.text = categories[indexPath.row]["desc"]!
        cell.backgroundColor = .clear
        return cell
    }

}
