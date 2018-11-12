//
//  EditNoteViewController.swift
//  Notes
//
//  Created by Aliaksei Verameichyk on 10/31/18.
//  Copyright © 2018 Aliaksei Verameichyk. All rights reserved.
//

import UIKit

class EditNoteViewController: UIViewController {
    // MARK: - Properties
    
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var subtitleTextView: UITextView!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    
    weak var delegate: EditNoteViewControllerDelegate?
    
    var viewModel: EditNoteViewViewModel?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel?.note != nil ? "Edit" : "Add"
        
        titleTextField.delegate = self
        subtitleTextView.delegate = self
        
        subtitleTextView.layer.cornerRadius = 5
        subtitleTextView.layer.borderColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        subtitleTextView.layer.borderWidth = 1
        
        updateUI()
    }
    
    // MARK: - Public methods
    
    func startLoading() {
        activityIndicatorView.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    func endLoading() {
        activityIndicatorView.stopAnimating()
        view.isUserInteractionEnabled = true
    }
    
    func showErrorMessage(_ message: String) {
        let alertController = UIAlertController(title: "Ошибка!",
                                                message: message,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK",
                                     style: .default)
        
        alertController.addAction(okAction)
        
        present(alertController,
                animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction private func saveButtonPressed(_ sender: UIBarButtonItem) {
        guard !(titleTextField.text?.isEmpty ?? true) else {
            let alertController = UIAlertController(title: "Неверный формат заметки!",
                                                    message: "Заметка должна иметь название!",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK",
                                         style: .default)
            
            alertController.addAction(okAction)
            
            present(alertController,
                    animated: true)
            
            return
        }
        
        guard let oldNote = viewModel?.note else {
            let newNote = Note(id: Int64(arc4random_uniform(UInt32.max)),
                               title: titleTextField.text ?? "",
                               description: subtitleTextView.text)
            
            delegate?.controller(self,
                                 didAddNote: newNote)
            
            return
        }
        
        let changedNote = Note(id: oldNote.id,
                               title: titleTextField.text ?? "",
                               description: subtitleTextView.text)
        
        delegate?.controller(self,
                             didEditNote: changedNote)
    }
    
    // MARK: - Private methods
    
    private func updateUI() {
        titleTextField.text = viewModel?.title
        subtitleTextView.text = viewModel?.description
    }
}

// MARK: - Implementation UITextFieldDelegate

extension EditNoteViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return (textField.text?.count ?? 0) + string.count <= 250
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}

// MARK: - Implementation UITextViewDelegate

extension EditNoteViewController: UITextViewDelegate {
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        guard text != "\n" else {
            textView.endEditing(true)
            return false
        }
        
        return (textView.text?.count ?? 0) + text.count <= 1000
    }
}
