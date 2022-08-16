//
//  CategoriesTableViewController.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 14/07/2022.
//

import UIKit

protocol CategoriesTableVcDelegate {
    func pushRoom(viewController vc: UIViewController) -> ()
}

class CategoriesTableViewController: UITableViewController {
    
    static var delegate: CategoriesTableVcDelegate?
    
    private let tempDict = [
        ["title":"History 📖","desc":"Discuss history and newest conventions in history."],
        ["title":"Politics 📋","desc":"Discuss politics and newest conventions in politics."],
        ["title":"Economics 📉","desc":"Discuss economics and newest conventions in economy."],
        ["title":"Law 📜","desc":"Discuss law and newest conventions in law."],
        ["title":"Technology 🤖","desc":"Discuss technology and newest conventions in technology."],
        ["title":"Science 🪐","desc":"Discuss science and newest conventions in science."],
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.Colors.primary
        tableView.register(CategoriesTableViewCell.self, forCellReuseIdentifier: CategoriesTableViewCell.identifier)
        tableView.separatorStyle = .none
        
    }
    
    private func openLoadingVC(withCategory category:String) {
        let vc = LoadingViewController()
        vc.categoryLabel.text = category
        CategoriesTableViewController.delegate?.pushRoom(viewController: vc)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempDict.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openLoadingVC(withCategory: tempDict[indexPath.row]["title"]!)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoriesTableViewCell.identifier, for: indexPath) as? CategoriesTableViewCell else { return UITableViewCell() }
        
        cell.selectionStyle = .none
        cell.categoryTitle.text = tempDict[indexPath.row]["title"]!
        cell.categoryDescription.text = tempDict[indexPath.row]["desc"]!

        return cell
    }

}
