//
//  PostAnnotateImageRequest.swift
//  Sansan-Mobile-Internship
//
//  Created by Kawabe Masashi on 2020/06/29.
//  Copyright © 2020 Kotaro Fukuo. All rights reserved.
//

import Foundation
import APIKit

/// TODO: 課題2
// bodyParametersを設定する
// response関数を実装し、レスポンスをImagesResponseにパースする

// API仕様はこちらを参照
// https://cloud.google.com/vision/docs/detecting-fulltext?hl=ja
// https://cloud.google.com/vision/docs/reference/rest/v1/images/annotate?hl=ja#AnnotateImageRequest
struct PostAnnotateImageRequest: Request {
    typealias Response = ImagesResponse
    var apiKey: String
    var base64String: String
    
    var baseURL: URL {
        return URL(string: "https://vision.googleapis.com")!
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "/v1/images:annotate"
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
                    "type": "TEXT_DETECTION",
                    "maxResults": 10,
                ]]
            ]
        ]
        
        return JSONBodyParameters(JSONObject: json)
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        let decoder = JSONDecoder()
        guard let dictionary = object as? [String: Any],
              let data = try? JSONSerialization.data(withJSONObject: dictionary),
              let imageResponse = try? decoder.decode(ImagesResponse.self, from: data) else {
            throw ResponseError.unexpectedObject(object)
        }
        
        return imageResponse
    }
}
