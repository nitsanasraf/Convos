//
//  TabBarViewController.swift
//  Convos
//
//  Created by Nitsan Asraf on 14/08/2022.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    struct Screen {
        let viewController: UIViewController
        let icon: String
        let navBarTitle: String
    }
    
    private let networkManager = NetworkManger()
    
    private let screens = [
        Screen(viewController: CategoriesViewController(), icon: "house.fill", navBarTitle: "Categories"),
        Screen(viewController: StatisticsViewController(), icon: "chart.bar.fill", navBarTitle: "Statistics"),
        Screen(viewController: SettingsViewController(), icon: "gearshape.fill", navBarTitle: "Settings"),
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        var tabVCS = [UINavigationController]()
        
        
        for (i,screen) in screens.enumerated() {
            screen.viewController.title = screen.navBarTitle
            let navVC = UINavigationController(rootViewController: screen.viewController)
            navVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: screen.icon), tag: i+1)
            tabVCS.append(navVC)
        }
        
        setViewControllers(tabVCS, animated: false)
        
        tabBar.tintColor = .label
    }
    
}
