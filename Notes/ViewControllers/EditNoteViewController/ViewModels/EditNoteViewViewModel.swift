//
//  EditNoteViewViewModel.swift
//  Notes
//
//  Created by Aliaksei Verameichyk on 10/31/18.
//  Copyright © 2018 Aliaksei Verameichyk. All rights reserved.
//

import Foundation

struct EditNoteViewViewModel {
    // MARK: - Properties
    
    private(set) var note: Note?
    
    var title: String? {
        return note?.title
    }
    
    var description: String? {
        return note?.description
    }
    
    // MARK: - Life cycle
    
    init(note: Note?) {
        self.note = note
    }
}
