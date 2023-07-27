//
//  AnnotateImage.swift
//  Sansan-Mobile-Internship
//
//  Created by Tomoki Hirayama on 2023/07/22.
//  Copyright © 2023 Sansan. All rights reserved.
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
