//
//  APIClient.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/09.
//

import Foundation
import Alamofire
import PromisedFuture

/// Alomfire를 통한 API 연동
class APIClient {
    //MARK: - API 연동
    /// API 연동 - Alamofire
    /// - Parameters:
    ///   - route: URL Request
    ///   - decoder: JSON Decoder
    /// - Returns: Future<T, AFError>
    @discardableResult
    public func request<T: Decodable>(route: APIRouter, decoder: JSONDecoder = JSONDecoder()) -> Future<T, AFError> {
        
        return Future { (completion) in
            let request = AF.request(route)
            request.responseDecodable(decoder: decoder, completionHandler: { (response: DataResponse<T, AFError>) in
                switch response.result{
                //API 연동 성공
                case .success(let value):
                    completion(.success(value))
                //API 연동 실패
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
    }
}
