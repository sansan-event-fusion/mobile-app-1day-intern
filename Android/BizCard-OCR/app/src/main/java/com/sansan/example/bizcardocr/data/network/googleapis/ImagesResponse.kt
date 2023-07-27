package com.sansan.example.bizcardocr.data.network.googleapis

data class ImagesResponse(
    val responses: List<AnnotateImageResponse>
)

data class AnnotateImageResponse(
    val textAnnotations: List<EntityAnnotation>?,
    val fullTextAnnotation: TextAnnotation?
)

data class EntityAnnotation(
    val locale: String,
    val description: String
)

data class TextAnnotation(
    val text: String
)
