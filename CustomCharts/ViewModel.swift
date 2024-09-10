//
//  ViewModel.swift
//  CustomCharts
//
//  Created by Arthur Sobrosa on 06/09/24.
//

import Foundation

class ViewModel {
    var limits: [Int] = [7, 15, 30]
    lazy var selectedLimit = self.limits[0]
    
    var limitsIndexes = [Int]()
    
    func getRandomData(length: Int = Int.random(in: 0...100)) -> [MockedData] {
        let percentages = (0..<length).map { _ in Double.random(in: 0.0...1.0) }
        let dates = (0..<length).map { _ in
            let startDate = DateComponents(calendar: .current, year: 2024, month: 1, day: 1).date!
            let endDate = DateComponents(calendar: .current, year: 2024, month: 12, day: 31).date!
            let interval = endDate.timeIntervalSince(startDate)
            return startDate.addingTimeInterval(TimeInterval(arc4random_uniform(UInt32(interval))))
        }
        
        let mockedDataArray = (0..<length).map { index in
            let mockedData = MockedData(percentage: percentages[index], date: dates[index])
            return mockedData
        }
        
        return mockedDataArray
    }
}

class MockedData: Comparable {
    var percentage: Double
    var date: Date
    
    init(percentage: Double, date: Date) {
        self.percentage = percentage
        self.date = date
    }
    
    static func == (lhs: MockedData, rhs: MockedData) -> Bool {
        return lhs.date == rhs.date
    }
    
    static func < (lhs: MockedData, rhs: MockedData) -> Bool {
        return lhs.date < rhs.date
    }
}
