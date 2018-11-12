//
//  Protocols.swift
//  Notes
//
//  Created by Aliaksei Verameichyk on 10/31/18.
//  Copyright © 2018 Aliaksei Verameichyk. All rights reserved.
//

import Foundation
import SwiftyJSON

public protocol ResponseJSONObjectSerializable {
    init?(json: JSON)
}
