//
//  ImageResponse.swift
//  Sansan-Mobile-Internship
//
//  Created by Fukuo Kotaro on 2019/07/12.
//  Copyright © 2018 Kotaro Fukuo. All rights reserved.
//

import Foundation

struct ImagesResponse: Codable {
    var responses: [AnnotateImageResponse]
}

struct AnnotateImageResponse: Codable {
    var textAnnotations: [EntityAnnotation]?
    var fullTextAnnotation: TextAnnotation?
}

struct EntityAnnotation: Codable {
    var locale: String?
    var description: String?
}

struct TextAnnotation: Codable {
    var text: String?
}
