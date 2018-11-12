//
//  NotesViewController.swift
//  Notes
//
//  Created by Aliaksei Verameichyk on 10/31/18.
//  Copyright © 2018 Aliaksei Verameichyk. All rights reserved.
//

import UIKit

protocol EditNoteViewControllerDelegate: class {
    func controller(_ controller: EditNoteViewController,
                    didEditNote note: Note)
    func controller(_ controller: EditNoteViewController,
                    didAddNote note: Note)
}

class NotesViewController: UIViewController {
    // MARK: - Properties
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    
    private let refreshControl = UIRefreshControl()
    
    var viewModel: NoteViewViewModel? {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.addSubview(refreshControl)
        tableView.tableFooterView = UIView()
        
        refreshControl.addTarget(self,
                                 action: #selector(forceUpdate),
                                 for: .valueChanged)
    }
    
    // MARK: - Public methods
    
    func updateUI() {
        tableView.reloadData()
    }
    
    func startLoading() {
        activityIndicatorView.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    func endLoading() {
        activityIndicatorView.stopAnimating()
        refreshControl.endRefreshing()
        view.isUserInteractionEnabled = true
    }
    
    // MARK: - Private methods
    
    @objc private func forceUpdate() {
        viewModel?.forceUpdate()
    }
    
    // MARK: - Actions
    
    @IBAction private func addButtonPressed(_ sender: UIBarButtonItem) {
        guard let editNoteVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditNoteViewController") as? EditNoteViewController else { return }
        
        editNoteVC.delegate = self
        
        navigationController?.pushViewController(editNoteVC,
                                                 animated: true)
    }
}

// MARK: - Implementation UITableViewDataSource

extension NotesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.numberOfSections ?? 1
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfNotes ?? 0
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell",
                                                 for: indexPath) as! NoteCell
        
        if let viewModel = viewModel {
            cell.configureView(with: viewModel.title(for: indexPath.row),
                               subtitle: viewModel.description(for: indexPath.row))
        }
        
        return cell
    }
}

// MARK: - Implementation UITableViewDelegate

extension NotesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath,
                              animated: true)
        
        guard let note = viewModel?.note(for: indexPath.row) else { return }
        guard let editNoteVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditNoteViewController") as? EditNoteViewController else { return }
        
        editNoteVC.viewModel = EditNoteViewViewModel(note: note)
        editNoteVC.delegate = self
        
        navigationController?.pushViewController(editNoteVC,
                                                 animated: true)
    }
    
    func tableView(_ tableView: UITableView,
                   editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { [weak self] action, indexPath in
            self?.viewModel?.removeNote(by: indexPath.row)
        }
        
        return [deleteAction]
    }
}

// MARK: - Implementation EditNoteViewControllerDelegate

extension NotesViewController: EditNoteViewControllerDelegate {
    func controller(_ controller: EditNoteViewController,
                    didAddNote note: Note) {
        controller.startLoading()
        
        viewModel?.addNote(note) { error in
            controller.endLoading()
            
            guard error == nil else {
                if let error = error as? ServiceError, let errorDescription = error.errorDescription {
                    controller.showErrorMessage(errorDescription)
                } else {
                    controller.showErrorMessage("Заметка не может быть добавлена, повторите попытку позже!")
                }
                
                return
            }
            
            controller.navigationController?.popViewController(animated: true)
        }
    }
    
    func controller(_ controller: EditNoteViewController,
                    didEditNote note: Note) {
        controller.startLoading()
        
        viewModel?.changeNote(note) { error in
            controller.endLoading()
            
            guard error == nil else {
                if let error = error as? ServiceError, let errorDescription = error.errorDescription {
                    controller.showErrorMessage(errorDescription)
                } else {
                    controller.showErrorMessage("Заметка не может быть изменена, повторите попытку позже!")
                }
                
                return
            }
            
            controller.navigationController?.popViewController(animated: true)
        }
    }
}
