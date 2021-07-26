//
//  APIRouter.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/09.
//

import Alamofire

/// API 연동을 위한 요청 URL 변환
enum APIRouter: URLRequestConvertible {
    
    //Request Method
    case post(useApi: String, path: String, parameters: [String: Any], isUpload: Bool)  //POST
    case get(useApi: String, path: String, parameters: [String: String])    //GET
    
    //static let baseApiUrl: String = "http:/172.30.1.7:8080"
    static let baseApiUrl: String = "http://101.101.219.152:8080"   //악취 모니터링 API URL
    static let weatherApiUrl: String = "http://apis.data.go.kr/1360000"    //기상청 초단기예보 API URL
    
    //MARK: - Base URL
    private var baseUrl: String {
        //사용할 API에 따른 Base URL 지정
        switch self {
        //POST - Base URL
        case .post(let useApi, _, _, _):
            switch useApi {
            case "base":
                return APIRouter.baseApiUrl
            case "weather":
                return APIRouter.weatherApiUrl
            default:
                return APIRouter.baseApiUrl
            }
        //GET - Base URL
        case .get(let useApi, _, _):
            switch useApi {
            case "base":
                return APIRouter.baseApiUrl
            case "weather":
                return APIRouter.weatherApiUrl
            default:
                return APIRouter.baseApiUrl
            }
        }
    }
    
    //MARK: - HTTP Method
    private var method: HTTPMethod {
        switch self {
        case .post:
            return .post
        case .get:
            return .get
        }
    }
    
    //MARK: - Path
    private var path: String {
        switch self {
        case .post(_, let path, _, _):
            return path
        case .get(_, let path, _):
            return path
        }
    }
    
    //MARK: - Parameters
    private var parameters: Parameters? {
        switch self {
        case .post(_, _, let parameters, _):
            return parameters
        case .get(_, _, let parameters):
            return parameters
        }
    }
        
    // MARK: - URL 요청 변환
    /// 요청 URL 변환
    /// - Throws: URLRequest
    /// - Returns: URLRequest
    func asURLRequest() throws -> URLRequest {
        //MARK: - URL
        let url = try baseUrl.asURL()   //API URL
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))  //Base URL + Path
        
        //MARK: - Method
        urlRequest.httpMethod = method.rawValue

        //MARK: - Headers
        switch self {
        case .post(_, _, _, let isUpload):
            //업로드할 파일이 없는 경우
            if !isUpload {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            }
            //업로드할 파일이 있는 경우 - Content-Type: multipart/form-data 설정
            else {
                urlRequest.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
            }
        case .get:
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        }

        //MARK: - Parameters
        switch self {
        case .post(_, _, let parameters, _):
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])   //JSON Parsing
            } catch {
                throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
            }
        case .get(_, _, let parameters):
            urlRequest = try URLEncodedFormParameterEncoder().encode(parameters, into: urlRequest)
        }
        
        return urlRequest
    }
}
