//
//  APIClient.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/09.
//
import SwiftUI
import Foundation
import Alamofire
import PromisedFuture

/// Alomfire를 통한 API 연동
class APIClient {
    //MARK: - API Request 연동
    /// API Request 연동 - Alamofire
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
    
    //MARK: - API Upload 연동
    /// API Upload 연동 - Alamofire
    /// - Parameters:
    ///   - route: URL Request
    ///   - parameters: Multipart Form Data
    ///   - images: UIImage Array
    ///   - decoder: JSON Decoder
    /// - Returns: Future<T, AFError>
    public func upload<T: Decodable>(route: APIRouter, parameters: [String:Any], images: [UIImage], decoder: JSONDecoder = JSONDecoder()) -> Future<T, AFError> {

        return Future { (completion) in
            let upload = AF.upload(
                //Multipart Form Data 변환
                multipartFormData: { multipartFormData in
                    //Paramers
                    for (key, value) in parameters {
                        if let temp = value as? String {
                            multipartFormData.append(temp.data(using: .utf8)!, withName: key)
                        }
                    }
                    
                    //Image
                    for (index, image) in images.enumerated() {
                        let withName = "img" + String(index + 1)    //이미지 Key
                        let imageData = image.jpegData(compressionQuality: 0.5) //이미지 파일

                        //Data(이미지 데이터), withName: Key, fileName: 파일명 + 확장자, mimeType: 파일형식
                        multipartFormData.append(imageData!, withName: withName, fileName: ".jpeg", mimeType: "image/jpeg")
                    }
                },
                with: route //API Router
            )
            
            upload.responseDecodable(decoder: decoder, completionHandler: { (response: DataResponse<T, AFError>) in
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
