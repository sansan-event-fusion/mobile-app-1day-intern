//
//  GoogleAPIRequest.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/08.
//

import Foundation

struct GoogleAPIRequest: APIRequest {
    struct ResponseBody: Decodable {
        let responses: [AnnotateImage]
    }

    typealias Response = ResponseBody

    struct GoogleAPIRequestHeader: APIRequestHeader {
        var headers: [String: String] {
            ["Content-Type": "application/json"]
        }
    }

    struct GoogleAPIRequestQueryParameter: APIRequestQueryParameter {
        var parameters: [String: String] {
            ["key": Config.googleAPIKey]
        }
    }

    struct GoogleAPIRequestBodyParameter: APIRequestBodyParameter {
        let base64String: String

        var bodyParameters: [String: Any] {
            [
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
        }
    }

    var baseURL: URL {
        URL(string: "https://vision.googleapis.com")!
    }

    var path: String {
        "/v1p4beta1/images:annotate"
    }

    var method: String {
        "POST"
    }

    var header: APIRequestHeader {
        GoogleAPIRequestHeader()
    }

    var queryParameters: APIRequestQueryParameter {
        GoogleAPIRequestQueryParameter()
    }

    let bodyParameters: APIRequestBodyParameter

    init(imageData: Data) {
        bodyParameters = GoogleAPIRequestBodyParameter(base64String: imageData.base64EncodedString())
    }
}
