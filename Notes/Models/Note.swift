//
//  Note.swift
//  Notes
//
//  Created by Aliaksei Verameichyk on 10/31/18.
//  Copyright © 2018 Aliaksei Verameichyk. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Note: ResponseJSONObjectSerializable {
    // MARK: - Properties
    
    let id: Int64
    let title: String
    let description: String?
    
    var json: [String : Any] {
        return ["id" : id,
                "title" : title,
                "description" : description ?? ""]
    }
    
    // MARK: - Life cycle
    
    init(json: JSON) {
        id = json["id"].int64 ?? 0
        title = json["title"].string ?? ""
        description = json["description"].string
    }
    
    init(id: Int64,
         title: String,
         description: String?) {
        self.id = id
        self.title = title
        self.description = description
    }
}
