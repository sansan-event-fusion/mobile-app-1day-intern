//
//  AnnotateImageAPI.swift
//  Sansan-Mobile-Internship
//
//  Created by Tomoki Hirayama on 2023/07/22.
//  Copyright © 2023 Sansan. All rights reserved.
//

import APIKit
import Foundation
import RxSwift

protocol AnnotateImageAPIInterface {
    func postAnnotateImage(imageBase64String: String) -> Single<AnnotateImagePostRequest.Response>
}

struct AnnotateImageAPI: AnnotateImageAPIInterface {
    let apiKey: String

    func postAnnotateImage(imageBase64String: String) -> RxSwift.Single<AnnotateImagePostRequest.Response> {
        let request = AnnotateImagePostRequest(apiKey: AppConstants.API.key, base64String: imageBase64String)
        return .create { observer in
            let session = Session.send(request) { result in
                switch result {
                case let .success(response):
                    observer(.success(response))
                case let .failure(error):
                    observer(.failure(error))
                }
            }

            return Disposables.create {
                session?.cancel()
            }
        }
    }
}

// API仕様はこちらを参照
// https://cloud.google.com/vision/docs/detecting-fulltext?hl=ja
// https://cloud.google.com/vision/docs/reference/rest/v1/images/annotate?hl=ja#AnnotateImageRequest
struct AnnotateImagePostRequest: Request {
    struct ResponseBody: Decodable {
        let responses: [AnnotateImage]
    }

    typealias Response = ResponseBody

    var apiKey: String
    var base64String: String

    var baseURL: URL {
        return URL(string: "https://vision.googleapis.com")!
    }

    var method: HTTPMethod {
        return .post
    }

    var path: String {
//        return "/v1/images:annotate"
        return "/v1p4beta1/images:annotate"
    }

    var queryParameters: [String: Any]? {
        return [
            "key": apiKey
        ]
    }

    var bodyParameters: BodyParameters? {
        let json: [String: Any] = [
            "requests": [
                "image": [
                    "content": "\(base64String)"
                ],
                "features": [[
                    "type": "DOCUMENT_TEXT_DETECTION",
                    "maxResults": 30,
                    "model": "builtin/latest"
                ]]
            ]
        ]

        return JSONBodyParameters(JSONObject: json)
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        // ResponseがDecodableに準拠していなければパースされない
        guard let response = object as? Response else {
            throw ResponseError.unexpectedObject(object)
        }
        return response
    }
}
