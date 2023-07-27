package com.sansan.example.bizcardocr.data.network.googleapis

data class ImagesRequest(
    val requests: List<AnnotateImageRequest>
) {
    companion object {
        fun createSingleRequest(
            base64Image: String,
            type: Feature.Type,
            maxResults: Int = 10
        ): ImagesRequest {
            val requests: List<AnnotateImageRequest> = listOf(
                AnnotateImageRequest(
                    Image(base64Image),
                    listOf(Feature(type, maxResults)),
                    ImageContext(
                        listOf(
                            LanguageHint.JAPANESE.language,
                            LanguageHint.ENGLISH.language
                        )
                    )
                )
            )
            return ImagesRequest(requests)
        }
    }
}

data class AnnotateImageRequest(
    val image: Image,
    val features: List<Feature>,
    val imageContext: ImageContext
)

data class Image(
    val content: String // base-64 string
)

data class Feature(
    val type: Type,
    val maxResults: Int
) {
    enum class Type { DOCUMENT_TEXT_DETECTION }
}

data class ImageContext(
    val languageHints: List<String>
)

enum class LanguageHint(val language: String) {
    JAPANESE("ja"),
    ENGLISH("en")
}
