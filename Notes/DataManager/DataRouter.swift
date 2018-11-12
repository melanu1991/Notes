//
//  DataRouter.swift
//  Notes
//
//  Created by Aliaksei Verameichyk on 10/31/18.
//  Copyright © 2018 Aliaksei Verameichyk. All rights reserved.
//

import Foundation
import Alamofire

enum DataRouter: URLRequestConvertible {
    // MARK: - Properties
    
    static let personalKey = "al4uirjvcikr"
    static let baseURLString = "https://profigroup.by/applicants-tests/mobile/v2"
    
    case notes
    case updateNotes([Parameters])
    
    // MARK: - Public methods
    
    func asURLRequest() -> URLRequest {
        var method: HTTPMethod {
            switch self {
            case .notes: return .get
            case .updateNotes: return .put
            }
        }
        
        let result: (path: String, parameters: [Parameters]?) = {
            switch self {
            case .notes: return ("/\(DataRouter.personalKey)", nil)
            case .updateNotes(let parameters): return ("/\(DataRouter.personalKey)", parameters)
            }
        }()
        
        let url = URL(string: DataRouter.baseURLString)!
        var urlRequest = URLRequest(url: url.appendingPathComponent(result.path))
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue("application/json; charset=UTF-8",
                            forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json",
                            forHTTPHeaderField: "Accept")
        
        debugPrint("--- HttpHeaders ---")
        debugPrint(urlRequest.allHTTPHeaderFields ?? "")
        debugPrint("--- URL ---")
        debugPrint(urlRequest.url ?? "")
        debugPrint("--- Parameters ---")
        debugPrint(result.parameters ?? "")
        
        return try! JSONEncoding.default.encode(urlRequest,
                                                withJSONObject: result.parameters)
    }
}
