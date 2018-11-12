//
//  NoteCell.swift
//  Notes
//
//  Created by Aliaksei Verameichyk on 10/31/18.
//  Copyright © 2018 Aliaksei Verameichyk. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell {
    // MARK: - Properties
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    // MARK: - Public methods
    
    func configureView(with title: String,
                       subtitle: String?) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}
