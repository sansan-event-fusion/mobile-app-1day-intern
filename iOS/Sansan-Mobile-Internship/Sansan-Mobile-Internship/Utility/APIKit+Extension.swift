//
//  APIKit+Extension.swift
//  Sansan-Mobile-Internship
//
//  Created by Tomoki Hirayama on 2023/07/26.
//  Copyright © 2023 Sansan. All rights reserved.
//

import APIKit
import Foundation

final class EntityDataParser<T: Decodable>: APIKit.DataParser {
    var contentType: String? {
        return "application/json"
    }

    func parse(data: Data) throws -> Any {
        return try JSONDecoder().decode(T.self, from: data)
    }
}

extension APIKit.Request where Self.Response: Decodable {

    var dataParser: APIKit.DataParser {
        return EntityDataParser<Response>()
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let entity = object as? Response else {
            throw ResponseError.unexpectedObject(object)
        }
        return entity
    }
}
