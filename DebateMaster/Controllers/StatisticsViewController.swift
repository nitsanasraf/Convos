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
        guard let parent = self.parent else {return}

        networkManager.fetchData(type: UserModel.self, url: "\(networkManager.usersURL)/\(userID)", withEncoding: true) { [weak self] (statusCode,user,_) in
            guard let self = self else {return}
            self.networkManager.handleErrors(statusCode: statusCode, viewController: parent)
            guard let user = user else {return}
            UserModel.shared.categoriesCount = user.categoriesCount
            UserModel.shared.createdAt = user.createdAt
            completionHandler()
        }
    }
    
    private func createSection(content: UIView, withLabel label: UIView?) -> UIStackView {
        let stack = UIStackView()
        stack.backgroundColor = .init(white: 0, alpha: 0.1)
        stack.layer.cornerRadius = 10
        stack.clipsToBounds = true
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        stack.spacing = 10
        stack.axis = .vertical
        if let label = label {
            stack.addArrangedSubviews(label, content)
        } else {
            stack.addArrangedSubview(content)
        }
        return stack
    }
    
    private lazy var createdAtLabel: BRLabel = {
        guard let createdTimeStamp = UserModel.shared.createdAt else { return BRLabel() }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        guard let date = dateFormatter.date(from: createdTimeStamp) else { return BRLabel() }
        let components = Calendar.current.dateComponents([.day], from: date , to: Date())
        
        guard let totalDays = components.day else { return BRLabel() }
        
        let totalDaysAgo = totalDays < 1 ? "Less than a day ago" : (totalDays == 1 ? "\(totalDays) day ago" : "\(totalDays) days ago")
        let label = BRLabel(boldText: "Account created: ", regularText: totalDaysAgo , ofSize: 15)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var favouriteLabel: BRLabel = {
        var label = BRLabel()
        let size = 15.0
        if let category = UserModel.shared.getFavouriteCategory() {
            label = BRLabel(boldText: "Favourite category: ", regularText: category, ofSize: size)
        } else {
            label = BRLabel(boldText: "Favourite category: ", regularText: "No favourite yet 🤔", ofSize: size)
        }
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let barChartView: BarChartView = {
        let chart = BarChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.heightAnchor.constraint(equalToConstant: 230).isActive = true
        chart.legend.enabled = false
        chart.rightAxis.enabled = false
        chart.leftAxis.axisMinimum = 0
        chart.leftAxis.gridColor = .systemPink
        
        chart.xAxis.drawGridLinesEnabled = false
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
    
    private lazy var roomsCountLabel: BRLabel = {
        let count = UserModel.shared.getTotalRoomsCount()
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        let totalRoomsCount = fmt.string(from: count as NSNumber)
        let label = BRLabel(boldText: "Total rooms: ", regularText: totalRoomsCount ?? "0", ofSize: 15.0)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let radarChartView: RadarChartView = {
        let chart = RadarChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.heightAnchor.constraint(equalToConstant: 300).isActive = true
        chart.rotationEnabled = false
        chart.legend.enabled = false
        chart.webColor = .systemPink
        chart.innerWebColor = .systemYellow
        
        chart.yAxis.axisMinimum = 0
        chart.yAxis.drawLabelsEnabled = false
        
        chart.xAxis.labelFont = .systemFont(ofSize: 10, weight: .bold)
        chart.xAxis.labelTextColor = Constants.Colors.primaryText
        
        chart.highlightPerTapEnabled = false
        return chart
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        barChartView.animate(yAxisDuration: 1, easingOption: .easeInSine)
        radarChartView.animate(yAxisDuration: 1, easingOption: .easeInSine)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGradient(colors: [Constants.Colors.primaryGradient, Constants.Colors.secondaryGradient])
        view.addBackgroundImage(with: "main.bg")

        view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        scrollView.delegate = self
        
        getUserData {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                self.activityIndicator.removeFromSuperview()
                
                self.setBarData()
                self.setRadarData()
                self.addViews()
                self.addLayouts()
            }
        }
    }
    
    private func setBarData() {
        guard let categoriesCount = UserModel.shared.categoriesCount else {return}
        
        var dataEntries = [ChartDataEntry]()
        for (ix,item) in categoriesCount.enumerated() {
            dataEntries.append(BarChartDataEntry(x: Double(ix), y: Double(item["count"]!) ?? 0))
        }
        let dataSet = BarChartDataSet(entries: dataEntries , label: nil)
        dataSet.highlightEnabled = false
        dataSet.setColor(.systemYellow, alpha: 0.45)
        dataSet.barBorderColor = .systemYellow
        dataSet.barBorderWidth = 1
        
        let data = BarChartData(dataSet: dataSet)
        data.setDrawValues(false)
        
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: categoriesCount.map { $0["category"]! })
        barChartView.data = data
    }
    
    private func setRadarData() {
        guard let categoriesCount = UserModel.shared.categoriesCount else {return}

        var dataEntries = [ChartDataEntry]()
        for (ix,item) in categoriesCount.enumerated() {
            dataEntries.append(BarChartDataEntry(x: Double(ix), y: Double(item["count"]!) ?? 0))
        }
        
        let dataSet = RadarChartDataSet(entries: dataEntries , label: nil)
        dataSet.highlightEnabled = false
        dataSet.drawFilledEnabled = true
        dataSet.setColor(.systemYellow)
        dataSet.fillColor = .systemYellow
        
        let data = RadarChartData(dataSet:dataSet)
        data.setDrawValues(false)
        
        radarChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: categoriesCount.map { $0["category"]! })
        radarChartView.data = data
    }
    
    
    private func addViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        stackView.addArrangedSubviews(createSection(content: createdAtLabel, withLabel: nil),
                                      createSection(content: barChartView, withLabel: favouriteLabel),
                                      createSection(content: radarChartView, withLabel: roomsCountLabel))
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

