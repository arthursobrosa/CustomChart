//
//  ViewController.swift
//  CustomCharts
//
//  Created by Arthur Sobrosa on 06/09/24.
//

import UIKit

class ViewController: UIViewController {
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl()
        
        control.translatesAutoresizingMaskIntoConstraints = false
        
        return control
    }()
    
    private lazy var customChart: CustomChart = {
        let chart = CustomChart(limit: self.viewModel.selectedLimit)
        
        chart.translatesAutoresizingMaskIntoConstraints = false
        
        return chart
    }()
    
    private lazy var reloadButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.setTitle("Reload data", for: .normal)
        
        button.addTarget(self, action: #selector(didTapReloadButton), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        
        self.setupUI()
        
        self.setSegmentedControl()
        
        self.setChart()
    }
    
    private func setSegmentedControl() {
        let limits = self.viewModel.limits
        let selectedLimit = self.viewModel.selectedLimit
        
        for (index, limit) in limits.enumerated() {
            let action = UIAction(title: String(limit)) { _ in
                self.viewModel.selectedLimit = self.viewModel.limits[index]
                
                self.customChart.changeLimit(to: self.viewModel.selectedLimit)
            }
            
            self.segmentedControl.insertSegment(action: action, at: index, animated: false)
            
            if limit == selectedLimit {
                self.segmentedControl.selectedSegmentIndex = index
            }
        }
    }
    
    private func setChart() {
        let randomData = self.viewModel.getRandomData()
        self.customChart.setData(randomData, sorter: \.date, mapTo: \.percentage)
    }
    
    @objc private func didTapReloadButton() {
        let randomData = self.viewModel.getRandomData()
        self.customChart.setData(randomData, sorter: \.date, mapTo: \.percentage)
        self.customChart.reloadCollection()
    }
}

private extension ViewController {
    func setupUI() {
        let stack = UIView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addSubview(segmentedControl)
        stack.addSubview(customChart)
        
        self.view.addSubview(stack)
        self.view.addSubview(reloadButton)
        
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            stack.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.25),
            
            segmentedControl.topAnchor.constraint(equalTo: stack.topAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: stack.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: stack.trailingAnchor, constant: -20),
            
            customChart.widthAnchor.constraint(equalTo: stack.widthAnchor, multiplier: 340/390),
            customChart.heightAnchor.constraint(equalTo: customChart.widthAnchor, multiplier: 163/340),
            customChart.centerXAnchor.constraint(equalTo: stack.centerXAnchor),
            customChart.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            
            reloadButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            reloadButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

