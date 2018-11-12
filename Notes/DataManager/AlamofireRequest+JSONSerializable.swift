//
//  AlamofireRequest+JSONSerializable.swift
//  Notes
//
//  Created by Aliaksei Verameichyk on 10/31/18.
//  Copyright © 2018 Aliaksei Verameichyk. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension Alamofire.DataRequest {
    @discardableResult
    func responseObject<T: ResponseJSONObjectSerializable>(completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        let serializer = DataResponseSerializer<T> { request, response, data, error in
            guard error == nil else { return .failure(error!) }
            
            guard let responseData = data else {
                return .failure(error!)
            }
            
            let result = Request.serializeResponseJSON(options: JSONSerialization.ReadingOptions.allowFragments,
                                                       response: response,
                                                       data: responseData,
                                                       error: error)
            
            switch result {
            case .success(let value):
                let json = SwiftyJSON.JSON(value)
                if let object = T(json: json) {
                    return .success(object)
                } else {
                    return .failure(error!)
                }
            case .failure(let error):
                return .failure(error)
            }
        }
        
        return response(responseSerializer: serializer,
                        completionHandler: completionHandler)
    }
    
    @discardableResult
    func responseArray<T: ResponseJSONObjectSerializable>(completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Self {
        let serializer = DataResponseSerializer<[T]> { request, response, data, error in
            guard error == nil else { return .failure(error!) }
            
            guard let responseData = data else {
                return .failure(error!)
            }
            
            let result = Request.serializeResponseJSON(options: JSONSerialization.ReadingOptions.allowFragments,
                                                       response: response,
                                                       data: responseData,
                                                       error: error)
            
            switch result {
            case .success(let value):
                let json = SwiftyJSON.JSON(value)
                
                var objects: [T] = []
                
                for (_, item) in json {
                    if let object = T(json: item) {
                        objects.append(object)
                    }
                }
                
                return .success(objects)
            case .failure(let error):
                return .failure(error)
            }
        }
        
        return response(responseSerializer: serializer,
                        completionHandler: completionHandler)
    }
}
