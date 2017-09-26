//
//  BaseService.swift
//  SlackUserList
//
//  Created by Rajath Bhagavathi on 7/26/17.
//  Copyright © 2017 ArrayFounder. All rights reserved.
//

import Foundation
import Alamofire

struct ServiceResult<T> {
    let object: T?
    let error: Error?
}

class BaseService: NSObject {
    
    typealias BaseCompletionHandler = (_ isSuccess: Bool, _ json: Any?, _ error: Error?) -> Void
    
    private static let XAppTokenHeader = "X-APP-AUTH-TOKEN"
    
    
    static let APIBaseHost = "https://slack.com/api"
    
    var currentRequest: Alamofire.DataRequest?
    
    func requestJSON(_ endpoint: String, method: Alamofire.HTTPMethod = .post, parameters: Parameters? = nil, encoding: ParameterEncoding = URLEncoding.queryString, headers: HTTPHeaders? = nil, completionHandler: @escaping BaseCompletionHandler) {
        
        
        let url = "\(BaseService.APIBaseHost)\(endpoint)"
        let currentRequest = request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
        self.currentRequest = currentRequest
        
        currentRequest.responseJSON { response in
            if response.response?.statusCode == 403 {
                // Handle error gracefully
            }
            completionHandler(response.result.isSuccess, response.result.value, response.result.error)
        }
    }
    
    func cancel() {
        self.currentRequest?.cancel()
    }
}
