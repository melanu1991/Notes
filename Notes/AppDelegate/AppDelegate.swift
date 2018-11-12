//
//  AppDelegate.swift
//  Notes
//
//  Created by Aliaksei Verameichyk on 10/31/18.
//  Copyright © 2018 Aliaksei Verameichyk. All rights reserved.
//

import UIKit
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: - Properties
    
    var window: UIWindow?

    // MARK: - Implementation UIApplicationDelegate
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        guard let navVC = window?.rootViewController as? UINavigationController else { return }
        guard let notesVC = navVC.viewControllers.filter({ $0 is NotesViewController }).first as? NotesViewController else { return }
        
        DataManager.shared.fetchNotes { notes, error in
            guard let notes = notes else { return }
            
            notesVC.viewModel = NoteViewViewModel(notes: notes)
            
            notesVC.viewModel?.notesDidChange = {
                notesVC.updateUI()
            }
            
            notesVC.viewModel?.operationStatusDidChange = { status in
                status ? notesVC.startLoading() : notesVC.endLoading()
            }
        }
    }
}
