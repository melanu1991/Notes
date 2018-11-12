//
//  DataManager.swift
//  Notes
//
//  Created by Aliaksei Verameichyk on 10/31/18.
//  Copyright © 2018 Aliaksei Verameichyk. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum ServiceError: Error {
    case custom(String)
}

extension ServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .custom(let message):
            return message
        }
    }
}


class DataManager {
    // MARK: - Properties
    
    static let shared = DataManager()
    
    private let alamofireManager: Alamofire.SessionManager
    
    // MARK: - Life cycle
    
    private init (){
        let configuration = URLSessionConfiguration.default
        
        alamofireManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    // MARK: - Public methods
    
    func fetchNotes(_ completionHandler: (([Note]?, Error?) -> Void)?) {
        Alamofire.request(DataRouter.notes).responseArray { (response: DataResponse<[Note]>) in
            completionHandler?(response.result.value,
                               response.result.error)
        }
    }

    func updateNotes(with parameters: [Parameters], completionHandler: ((Error?) -> Void)?) {
        Alamofire.request(DataRouter.updateNotes(parameters)).response { response in
            completionHandler?(response.error)
        }
    }
}
