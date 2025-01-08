//
//  FitnessRecord.swift
//  Fitness Tracker
//
//  Created by Taisheng Chen on 8.1.2025.
//

import Foundation

struct FitnessRecord: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var exerciseName: String
    var duration: Int
    var notes: String
}
