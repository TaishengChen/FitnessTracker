//
//  ContentView.swift
//  Fitness Tracker
//
//  Created by Taisheng Chen on 8.1.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var records: [FitnessRecord] = UserDefaults.standard.loadRecords()
    @State private var showingAddRecordView = false
    @State private var showDeleteConfirmation = false
    @State private var recordToDelete: FitnessRecord? = nil

    // record by date
    var groupedRecords: [String: [FitnessRecord]] {
        Dictionary(grouping: records, by: { record in
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: record.date)
        })
    }
    
//    extension ParameterType {
//        var unit: String {
//            switch self {
//            case .weight: return "kg"
//            case .speed: return "km/h"
//            }
//        }
//    }

    func saveRecords() {
        UserDefaults.standard.saveRecords(records)
    }
    
    func deleteRecord(_ record: FitnessRecord) {
        guard let index = records.firstIndex(where: { $0.id == record.id }) else {
            return
        }
        records.remove(at: index)
        saveRecords()
    }
    
    func unitForParameter(_ parameter: Parameter) -> String {
        switch parameter.name {
        case "Weight":
            return "kg"
        case "Speed":
            return "km/h"
        case "Duration":
            return "minutes"
        case "Sets", "Reps per Set":
            return ""
        default:
            return ""
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(groupedRecords.keys.sorted(), id: \.self) { date in
                    Section(header: Text(date)) {
                        ForEach(groupedRecords[date] ?? []) { record in
                            VStack(alignment: .leading) {
                                Text(record.exerciseName)
                                    .font(.headline)
                                ForEach(record.parameters) { parameter in
                                    HStack {
                                        Text("\(parameter.name):")
                                        Spacer()
                                        Text("\(parameter.value) \(unitForParameter(parameter))")
                                    }
                                    .font(.subheadline)
                                }
                                if !record.notes.isEmpty {
                                    Text("Notes: \(record.notes)")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    recordToDelete = record
                                    showDeleteConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Fitness Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddRecordView = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddRecordView) {
                AddRecordView { newRecord in
                    records.append(newRecord)
                    saveRecords()
                }
            }
            .alert("Delete Record", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let record = recordToDelete {
                        deleteRecord(record)
                    }
                    recordToDelete = nil
                }
            } message: {
                Text("Are you sure you want to delete this record?")
            }
        }
    }
}

struct AddRecordView: View {
    @Environment(\.dismiss) var dismiss
    @State private var exerciseName = ""
    @State private var selectedParameterType: ParameterType = .weight
    @State private var parameterValue = ""
    @State private var sets = ""
    @State private var reps = ""
    @State private var duration = ""
    @State private var selectedDate = Date()
    @State private var notes = ""

    var onSave: (FitnessRecord) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Exercise Name")) {
                    TextField("Enter Exercise Name", text: $exerciseName)
                }
                
                Section(header: Text("Parameter Type")) {
                    Picker("Parameter Type", selection: $selectedParameterType) {
                        ForEach(ParameterType.allCases, id: \.self) { type in
                            Text(type.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Parameter Details")) {
                    HStack {
                        TextField(selectedParameterType == .weight ? "Enter weight" : "Enter speed", text: $parameterValue)
                            .keyboardType(.decimalPad)
                        Text(selectedParameterType == .weight ? "kg" : "km/h")
                            .foregroundColor(.gray)
                    }
                    
                    if selectedParameterType == .weight {
                        HStack {
                            TextField("Sets", text: $sets)
                                .keyboardType(.numberPad)
                            Text("x")
                            TextField("Reps per Set", text: $reps)
                                .keyboardType(.numberPad)
                        }
                    } else if selectedParameterType == .speed {
                        HStack {
                            TextField("Duration (minutes)", text: $duration)
                                .keyboardType(.numberPad)
                        }
                    }
                }
                
                Section(header: Text("Date")) {
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(GraphicalDatePickerStyle())
                }
                
                Section(header: Text("Notes")) {
                    TextField("Add notes", text: $notes)
                }
            }
            .navigationTitle("Add Record")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if !exerciseName.isEmpty {
                            var parameters: [Parameter] = [
                                Parameter(
                                    name: selectedParameterType.rawValue,
                                    type: selectedParameterType,
                                    value: parameterValue
                                )
                            ]
                            
                            if selectedParameterType == .weight {
                                parameters.append(Parameter(name: "Sets", type: .weight, value: sets))
                                parameters.append(Parameter(name: "Reps per Set", type: .weight,  value: reps))
                            } else if selectedParameterType == .speed {
                                parameters.append(Parameter(name: "Duration", type: .speed, value: duration))
                            }
                            
                            let newRecord = FitnessRecord(
                                id: UUID(),
                                date: selectedDate,
                                exerciseName: exerciseName,
                                parameters: parameters,
                                notes: notes
                            )
                            onSave(newRecord)
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
