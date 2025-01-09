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

    var groupedRecords: [String: [FitnessRecord]] {
        Dictionary(grouping: records, by: { record in
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: record.date)
        })
    }

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

    var body: some View {
        NavigationView {
            List {
                ForEach(groupedRecords.keys.sorted(), id: \.self) { date in
                    Section(header: Text(date)) {
                        ForEach(groupedRecords[date] ?? []) { record in
                            VStack(alignment: .leading) {
                                Text(record.exerciseName)
                                Text("Duration: \(record.duration) minutes")
                                    .font(.subheadline)
                                Text(record.notes)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
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
                        recordToDelete = nil
                    }
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
    @State private var duration = ""
    @State private var notes = ""
    @State private var selectedDate = Date()

    var onSave: (FitnessRecord) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Exercise Details")) {
                    TextField("Exercise Name", text: $exerciseName)
                    TextField("Duration (minutes)", text: $duration)
                        .keyboardType(.numberPad)
                    TextField("Notes", text: $notes)
                }
                Section(header: Text("Date")) {
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(GraphicalDatePickerStyle())
                }
            }
            .navigationTitle("Add Record")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let durationInt = Int(duration), !exerciseName.isEmpty {
                            let newRecord = FitnessRecord(
                                id: UUID(),
                                date: selectedDate,
                                exerciseName: exerciseName,
                                duration: durationInt,
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
