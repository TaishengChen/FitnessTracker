//
//  UserDefaults.swift
//  Fitness Tracker
//
//  Created by Taisheng Chen on 9.1.2025.
//

import Foundation

extension UserDefaults {
    func saveRecords(_ records: [FitnessRecord]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(records) {
            set(encoded, forKey: "fitnessRecords")
        }
    }
    
    func loadRecords() -> [FitnessRecord] {
        if let saveData = data(forKey: "fitnessRecords") {
            let decoder = JSONDecoder()
            if let records = try? decoder.decode([FitnessRecord].self, from: saveData) {
                return records
            }
        }
        return []
    }
}
