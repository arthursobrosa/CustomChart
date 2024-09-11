//
//  CustomChart.swift
//  CustomCharts
//
//  Created by Arthur Sobrosa on 06/09/24.
//

import UIKit

class CustomChart: UIView {
    private var limit: Int
    
    private var rawData = [any Comparable]()
    private var filteredData = [any Comparable]()
    private var dataSize = Int()
    
    private let percentageIndexesStack: UIView = {
        let stack = UIView()
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    private let percentagesContainerView: UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var percentagesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .systemBackground
        
        collection.dataSource = self
        collection.delegate = self
        
        collection.register(PercentageCell.self, forCellWithReuseIdentifier: PercentageCell.identifier)
        
        collection.translatesAutoresizingMaskIntoConstraints = false
        
        return collection
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .label.withAlphaComponent(0.15)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    init(frame: CGRect = .zero, limit: Int) {
        self.limit = limit
        
        super.init(frame: frame)
        
        self.setupUI()
        
        self.setPercentageIndexesStack()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setPercentageIndexesStack() {
        let percentageIndexes = ["1.0", "0.5", "0"]
        
        for (index, percentageIndex) in percentageIndexes.enumerated() {
            let label = UILabel()
            label.text = percentageIndex
            label.font = .systemFont(ofSize: 13, weight: .semibold)
            label.textColor = .label
            label.translatesAutoresizingMaskIntoConstraints = false
            
            self.percentageIndexesStack.addSubview(label)
            
            var constraint = NSLayoutConstraint()
            
            switch index {
                case 0:
                    constraint = label.topAnchor.constraint(equalTo: self.percentageIndexesStack.topAnchor)
                case 1:
                    constraint = label.centerYAnchor.constraint(equalTo: self.percentageIndexesStack.centerYAnchor)
                case 2:
                    constraint = label.bottomAnchor.constraint(equalTo: self.percentageIndexesStack.bottomAnchor)
                default:
                    break
            }
            
            constraint.isActive = true
            label.centerXAnchor.constraint(equalTo: self.percentageIndexesStack.centerXAnchor).isActive = true
        }
    }
    
   func reloadCollection() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            self.percentagesCollectionView.reloadData()
        }
    }
    
    func changeLimit(to limit: Int) {
        self.limit = limit
        self.filterData()
        self.reloadCollection()
    }
    
    func setData<T, U, V>(_ data: [T], sorter keyPath: KeyPath<T, U>, mapTo resultKeyPath: KeyPath<T, V>, ascending: Bool = true) where U: Comparable, V: Comparable {
        self.dataSize = 0
        self.rawData = []
        self.filteredData = []
        
        let comparison: (T, T) -> Bool = ascending ? {
            $0[keyPath: keyPath] < $1[keyPath: keyPath]
        } : {
            $0[keyPath: keyPath] > $1[keyPath: keyPath]
        }
                
        let sortedData = data.sorted(by: comparison).map { $0[keyPath: resultKeyPath] }
        
        self.rawData = sortedData
        self.dataSize = data.count
        
        self.filterData()
    }
    
    private func filterData() {
        self.filteredData = self.limit <= self.dataSize ?
            Array(self.rawData.prefix(self.limit)) :
            self.rawData
    }
}

private extension CustomChart {
    func setupUI() {
        self.addSubview(percentageIndexesStack)
        self.addSubview(percentagesContainerView)
        self.addSubview(percentagesCollectionView)
        self.addSubview(dividerView)
        
        NSLayoutConstraint.activate([
            percentageIndexesStack.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 24/344),
            percentageIndexesStack.heightAnchor.constraint(equalTo: percentageIndexesStack.widthAnchor, multiplier: 148/24),
            percentageIndexesStack.topAnchor.constraint(equalTo: self.topAnchor),
            percentageIndexesStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            
            percentagesContainerView.heightAnchor.constraint(equalTo: percentagesContainerView.widthAnchor, multiplier: 132/288),
            percentagesContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 35),
            percentagesContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -21),
            percentagesContainerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 6),
            
            percentagesCollectionView.widthAnchor.constraint(equalTo: percentagesContainerView.widthAnchor),
            percentagesCollectionView.heightAnchor.constraint(equalTo: percentagesContainerView.heightAnchor),
            percentagesCollectionView.centerXAnchor.constraint(equalTo: percentagesContainerView.centerXAnchor),
            percentagesCollectionView.centerYAnchor.constraint(equalTo: percentagesContainerView.centerYAnchor),
            
            dividerView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 309/344),
            dividerView.heightAnchor.constraint(equalTo: dividerView.widthAnchor, multiplier: 2/309),
            dividerView.topAnchor.constraint(equalTo: percentagesContainerView.bottomAnchor, constant: 2),
            dividerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5)
        ])
    }
}

extension CustomChart: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.limit
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = indexPath.row
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PercentageCell.identifier, for: indexPath) as? PercentageCell else {
            fatalError("Could not dequeue cell")
        }
        
        var percentage = Double()
        var isEmpty = true
        
        if row < self.filteredData.count,
           let percent = self.filteredData[row] as? Double {
            isEmpty = false
            percentage = percent
        }
        
        cell.percentage = percentage
        cell.isEmpty = isEmpty
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfColumns = self.limit + (self.limit - 1)
        
        let size = CGSize(width: collectionView.bounds.width / Double(numberOfColumns), height: collectionView.bounds.height)
        
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let numberOfColumns = self.limit + (self.limit - 1)
        
        return collectionView.bounds.width / Double(numberOfColumns)
    }
}

class PercentageCell: UICollectionViewCell {
    static let identifier = "percentageCell"
    
    var percentage: Double? {
        didSet {
            guard let _ = percentage else { return }
            
            self.setupUI()
        }
    }
    
    var isEmpty: Bool? {
        didSet {
            guard let isEmpty else { return }
            
            self.percentageBackgroundView.backgroundColor = isEmpty ? .clear : .label.withAlphaComponent(0.06)
            self.percentageView.backgroundColor = isEmpty ? .clear : UIColor(named: "blueCustomColor")
        }
    }
    
    private let percentageBackgroundView: UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let percentageView: UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.percentageBackgroundView.layer.cornerRadius = self.bounds.width * (10/22)
        self.percentageView.layer.cornerRadius = self.percentageBackgroundView.layer.cornerRadius
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.contentView.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        
        self.percentage = nil
        self.isEmpty = nil
    }
}

private extension PercentageCell {
    func setupUI() {
        guard let percentage else { return }
        
        self.contentView.addSubview(percentageBackgroundView)
        self.contentView.addSubview(percentageView)
        
        NSLayoutConstraint.activate([
            percentageBackgroundView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor),
            percentageBackgroundView.heightAnchor.constraint(equalTo: self.contentView.heightAnchor),
            percentageBackgroundView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            percentageBackgroundView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            
            percentageView.widthAnchor.constraint(equalTo: percentageBackgroundView.widthAnchor),
            percentageView.heightAnchor.constraint(equalTo: percentageBackgroundView.heightAnchor, multiplier: percentage),
            percentageView.centerXAnchor.constraint(equalTo: percentageBackgroundView.centerXAnchor),
            percentageView.bottomAnchor.constraint(equalTo: percentageBackgroundView.bottomAnchor)
        ])
    }
}
