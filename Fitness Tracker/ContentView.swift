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
    @State private var expandedSections: Set<String> = []

    // Group records by date
    private var groupedRecords: [String: [FitnessRecord]] {
        Dictionary(grouping: records, by: { DateFormatter.localizedString(from: $0.date, dateStyle: .medium, timeStyle: .none) })
    }

    private func saveRecords() {
        UserDefaults.standard.saveRecords(records)
    }

    private func deleteRecord(_ record: FitnessRecord) {
        records.removeAll { $0.id == record.id }
        saveRecords()
    }

    private func toggleSection(_ date: String) {
        if expandedSections.contains(date) {
            expandedSections.remove(date)
        } else {
            expandedSections.insert(date)
        }
    }

    private func unitForParameter(_ parameter: Parameter) -> String {
        switch parameter.name {
        case "Weight": return "kg"
        case "Speed": return "km/h"
        case "Duration": return "minutes"
        case "Sets", "Reps per Set": return ""
        default: return ""
        }
    }

    var body: some View {
            NavigationView {
                ScrollView {
                    VStack(spacing: 16) { // 使用 VStack 代替 List
                        ForEach(groupedRecords.keys.sorted(), id: \.self) { date in
                            headerView(for: date) // 日期条
                                .frame(maxWidth: .infinity) // 日期条全宽
                                .padding(.horizontal)
                            
                            if expandedSections.contains(date) {
                                ForEach(groupedRecords[date] ?? []) { record in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(record.exerciseName).font(.headline)
                                        ForEach(record.parameters) { parameter in
                                            HStack {
                                                Text("\(parameter.name):")
                                                Spacer()
                                                Text("\(parameter.value) \(unitForParameter(parameter))")
                                            }
                                        }
                                        if !record.notes.isEmpty {
                                            Text("Notes: \(record.notes)")
                                                .font(.footnote)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding()
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(10)
                                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                                    .frame(maxWidth: UIScreen.main.bounds.width * 0.9) // 内容条宽度为屏幕宽度的 90%
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Fitness Tracker")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingAddRecordView = true }) {
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
                    }
                } message: {
                    Text("Are you sure you want to delete this record?")
                }
            }
        }

        private func headerView(for date: String) -> some View {
            Button(action: { toggleSection(date) }) {
                HStack {
                    Image(systemName: expandedSections.contains(date) ? "chevron.down" : "chevron.right")
                        .foregroundColor(.primary)
                    Text(date)
                        .font(.title3)
                        .bold()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(PlainButtonStyle())
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .shadow(radius: 2)
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
