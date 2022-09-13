//
//  CategoryModel.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 04/09/2022.
//

import UIKit

struct CategoryModel: Codable {
    let id: UUID?
    let title: String
    let description: String
    let icon: String
    
    static func getCategories(viewController vc: UIViewController, completionHandler: @escaping ([CategoryModel])->()) {
        let networkManager = NetworkManger()
        networkManager.fetchData(type: [CategoryModel].self, url: networkManager.categoriesURL, withEncoding: true) { (statusCode,categories,_) in
            networkManager.handleErrors(statusCode: statusCode, viewController: vc)
            guard let categories = categories else {return}
            completionHandler(categories)
        }
    }
}
