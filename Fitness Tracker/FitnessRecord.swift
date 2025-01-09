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
    var parameters: [Parameter]
    var notes: String = ""
}

enum ParameterType: String, Codable, CaseIterable {
    case weight = "Weight"
    case speed = "Speed"
}

struct Parameter: Codable, Identifiable {
    var id = UUID()
    var name: String
    var type: ParameterType
    var value: String
}
