//
//  NoteViewViewModel.swift
//  Notes
//
//  Created by Aliaksei Verameichyk on 10/31/18.
//  Copyright © 2018 Aliaksei Verameichyk. All rights reserved.
//

import Foundation

class NoteViewViewModel {
    // MARK: - Properties
    
    private var notes: [Note] = []
    
    var notesDidChange: (() -> Void)?
    var operationStatusDidChange: ((Bool) -> Void)?
    
    var numberOfNotes: Int {
        return notes.count
    }
    
    var numberOfSections: Int {
        return 1
    }
    
    // MARK: - Life cycle
    
    init(notes: [Note]) {
         self.notes = notes
    }
    
    // MARK: - Public methods
    
    func forceUpdate() {
        operationStatusDidChange?(true)
        
        DataManager.shared.fetchNotes { [weak self] notes, error in
            self?.operationStatusDidChange?(false)
            
            guard error == nil else {
                return
            }
            
            guard let notes = notes else {
                return
            }
            
            self?.notes = notes
            self?.notesDidChange?()
        }
    }
    
    func addNote(_ note: Note,
                 _ completionHandler: ((Error?) -> Void)?) {
        var tempNotes = notes
        tempNotes.append(note)
        
        let parameters = self.parameters(for: tempNotes)
        let isLimitMegabytes = self.isLimitMegabytes(for: parameters)
        
        guard !isLimitMegabytes else {
            completionHandler?(ServiceError.custom("Превышено количество памяти, выделенное для хранения заметок!"))
            
            return
        }
        
        DataManager.shared.updateNotes(with: parameters) { [weak self] error in
            guard error == nil else {
                completionHandler?(error)
                
                return
            }
            
            self?.notes = tempNotes
            self?.notesDidChange?()
            completionHandler?(nil)
        }
    }
    
    func changeNote(_ changedNote: Note,
                    _ completionHandler: ((Error?) -> Void)?) {
        guard let index = notes.index(where: { note in
            return note.id == changedNote.id
        }) else { return }
        
        var tempNotes = notes
        tempNotes[index] = changedNote
        
        let parameters = self.parameters(for: tempNotes)
        let isLimitMegabytes = self.isLimitMegabytes(for: parameters)
        
        guard !isLimitMegabytes else {
            completionHandler?(ServiceError.custom("Превышено количество памяти, выделенное для хранения заметок!"))
            
            return
        }
        
        DataManager.shared.updateNotes(with: parameters) { [weak self] error in
            guard error == nil else {
                completionHandler?(error)
                
                return
            }
            
            self?.notes = tempNotes
            self?.notesDidChange?()
            completionHandler?(nil)
        }
    }
    
    func removeNote(by index: Int) {
        var tempNotes = notes
        tempNotes.remove(at: index)
        
        let parameters = self.parameters(for: tempNotes)

        operationStatusDidChange?(true)
        
        DataManager.shared.updateNotes(with: parameters) { [weak self] error in
            self?.operationStatusDidChange?(false)
            
            guard error == nil else {
                return
            }
            
            self?.notes = tempNotes
            self?.notesDidChange?()
        }
    }
    
    func note(for index: Int) -> Note {
        return notes[index]
    }
    
    func title(for index: Int) -> String {
        return notes[index].title 
    }
    
    func description(for index: Int) -> String? {
        return notes[index].description
    }
    
    // MARK: - Private methods
    
    private func isLimitMegabytes(for parameters: [[String : Any]]) -> Bool {
        guard let data = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return true
        }
        
        let bytes = Double(data.count)
        let megabytes = bytes / (1024 * 1024)
        
        debugPrint("--- Megabytes ---")
        debugPrint(megabytes)
        
        guard megabytes <= 1.5 else {
            return true
        }
        
        return false
    }
    
    private func parameters(for notes: [Note]) -> [[String : Any]] {
        var parameters: [[String : Any]] = []
        
        notes.forEach { note in
            parameters.append(note.json)
        }
        
        return parameters
    }
}
