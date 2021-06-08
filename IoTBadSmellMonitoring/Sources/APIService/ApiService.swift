//
//  ApiService.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/07.
//

import Alamofire

class ApiService {
    
    enum Response<T> {
        case result
        case data(T)
        case pathError
        case serverError
        case networkError
    }
    
    func request(_ apiType: String, _ path: String, _ method: String, _ parameters: [String: Any], completionHandler: @escaping (DataResponse<Any, AFError>) -> Void) {
        
        var baseUrl: String = ""
        var requestUrl: String = ""

        if apiType == "base" {
            baseUrl = "http://172.30.1.49:8080"
        }
        else if apiType == "weather" {
            baseUrl = "http://apis.data.go.kr/1360000"
        }
        
        requestUrl = baseUrl + path
        print(requestUrl)
        
        let headers: HTTPHeaders = [
            "Content-Type" : "application/json",
            "Accept" : "application/json"
        ]
        
        if method == "GET" {
            requestGet(requestUrl, headers, parameters) { (response) in
                completionHandler(response)
            }
        }
        else if method == "POST" {
            requestGet(requestUrl, headers, parameters) { (response) in
                completionHandler(response)
            }
        }
    }
    
    func requestGet(_ url: String, _ headers: HTTPHeaders?, _ parameters: [String: Any], completionHandler: @escaping (DataResponse<Any, AFError>) -> Void) {

        let request = AF.request(url, method: .get, parameters: parameters, headers: headers)
        
        request.responseJSON {(response) in
            completionHandler(response)
        }
    }
    
    func requestPost(_ url: String, _ headers: HTTPHeaders?, _ parameters: [String: Any], completionHandler: @escaping (DataResponse<Any, AFError>) -> Void) {

        let request = AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        
        request.responseJSON {(response) in
            completionHandler(response)
        }
    }
}
