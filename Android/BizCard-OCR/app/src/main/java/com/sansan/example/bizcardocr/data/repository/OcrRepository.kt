package com.sansan.example.bizcardocr.data.repository

import android.util.Base64
import com.sansan.example.bizcardocr.data.network.ApiProvider
import com.sansan.example.bizcardocr.data.network.googleapis.Feature
import com.sansan.example.bizcardocr.data.network.googleapis.ImagesRequest
import com.sansan.example.bizcardocr.data.network.googleapis.ImagesResponse
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.withContext

object OcrRepository {

    private val ocrResult: MutableSharedFlow<ImagesResponse?> = MutableSharedFlow()

    suspend fun ocrRequest(rawImage: ByteArray) {
        val encodedImage = Base64.encodeToString(rawImage, Base64.NO_WRAP)
        val request =
            ImagesRequest.createSingleRequest(encodedImage, Feature.Type.DOCUMENT_TEXT_DETECTION)
        return withContext(Dispatchers.IO) {
            val result = kotlin.runCatching {
                ApiProvider.visionApi.images(request)
            }
            result.onSuccess {
                ocrResult.emit(it)
            }.onFailure {
                ocrResult.emit(null)
            }
        }
    }

    fun getOcrStream(): Flow<ImagesResponse?> {
        return ocrResult.asSharedFlow()
    }
}