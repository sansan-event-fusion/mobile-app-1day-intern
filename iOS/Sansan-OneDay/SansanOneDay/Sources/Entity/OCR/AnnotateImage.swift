//
//  AnnotateImage.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/02.
//

import Foundation

struct AnnotateImage: Decodable {
    let textAnnotations: [EntityAnnotation]?
    let fullTextAnnotation: TextAnnotation?

    struct EntityAnnotation: Decodable {
        let locale: String?
        let description: String?
    }

    struct TextAnnotation: Decodable {
        let text: String?
    }
}
