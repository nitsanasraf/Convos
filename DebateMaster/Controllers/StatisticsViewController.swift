//
//  StatisticsViewController.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 19/08/2022.
//

import UIKit
import Charts

class StatisticsViewController: UIViewController {
    
    private let networkManager = NetworkManger()
        
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let contentView: UIView = {
      let contentView = UIView()
      contentView.translatesAutoresizingMaskIntoConstraints = false
      return contentView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 10, left:20, bottom: 10, right: 20)
        return stackView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = Constants.Colors.primaryText
        indicator.style = .large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        return indicator
    }()
    
    private func getUserData(completionHandler: @escaping ()->()) {
        guard let userID = UserModel.shared.id else {return}
        networkManager.fetchData(type: UserModel.self, url: "\(networkManager.usersURL)/\(userID)") { user in
            UserModel.shared.categoriesCount = user.categoriesCount
            UserModel.shared.createdAt = user.createdAt
            completionHandler()
        }
    }
    
    private func createFavouriteLabel() -> BRLabel {
        var label = BRLabel()
        let size = 15.0
        if let category = UserModel.shared.getFavouriteCategory() {
            let emojiCategory = RoomModel.getEmojiName(categoryName: category)
            label = BRLabel(boldText: "Favourite category: ", regularText: emojiCategory, ofSize: size)
        } else {
            label = BRLabel(boldText: "Favourite category: ", regularText: "No favourite yet 🤔", ofSize: size)
        }
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }
    
    private let barChartView: BarChartView = {
        let chart = BarChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        chart.legend.setCustom(entries: [])
        
        chart.rightAxis.enabled = false
        chart.leftAxis.enabled = false
        chart.leftAxis.spaceBottom = 0
        chart.leftAxis.axisMinimum = 0
        
        chart.xAxis.gridColor = .systemPink
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.labelFont = .systemFont(ofSize: 10, weight: .bold)
        chart.xAxis.labelTextColor = Constants.Colors.primaryText
        chart.xAxis.axisLineColor = Constants.Colors.primaryText
        chart.xAxis.labelRotationAngle = -25

        chart.highlightPerTapEnabled = false
        chart.pinchZoomEnabled = false
        chart.doubleTapToZoomEnabled = false
        
        return chart
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        barChartView.animate(yAxisDuration: 1, easingOption: .easeInSine)

    }
    private func setData() {
        guard let categoriesCount = UserModel.shared.categoriesCount else {return}
        
        var values = [String]()
        for item in categoriesCount {
            values.append(item["category"]!)
        }
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: values)

        var dataEntries = [ChartDataEntry]()
        for (ix,item) in categoriesCount.enumerated() {
            dataEntries.append(BarChartDataEntry(x: Double(ix), y: Double(item["count"]!) ?? 0))
        }
        let dataSet = BarChartDataSet(entries: dataEntries , label: nil)
        dataSet.setColor(.systemCyan)
        dataSet.highlightEnabled = false
        
        let data = BarChartData(dataSet: dataSet)
        data.setDrawValues(false)
        
        barChartView.data = data
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGradient(colors: [Constants.Colors.primaryGradient, Constants.Colors.secondaryGradient])
        
        view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        scrollView.delegate = self
  
        getUserData {
            DispatchQueue.main.async {
                self.activityIndicator.removeFromSuperview()
                
                self.setData()
                self.addViews()
                self.addLayouts()
            }
        }
    }
    
    private func addViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        stackView.addArrangedSubviews(createFavouriteLabel(), barChartView)
    }
    
    private func addLayouts() {
        let scrollViewConstraints = [
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ]
        let contentViewConstraints = [
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ]
        let stackViewConstraints = [
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
        ]
        NSLayoutConstraint.activate(scrollViewConstraints)
        NSLayoutConstraint.activate(contentViewConstraints)
        NSLayoutConstraint.activate(stackViewConstraints)
    }
    


}


extension StatisticsViewController: UIScrollViewDelegate {}

