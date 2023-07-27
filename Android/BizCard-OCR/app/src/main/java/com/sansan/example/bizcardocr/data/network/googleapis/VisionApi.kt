package com.sansan.example.bizcardocr.data.network.googleapis

import com.sansan.example.bizcardocr.BuildConfig
import retrofit2.http.Body
import retrofit2.http.POST
import retrofit2.http.Query

interface VisionApi {
    @POST("v1/images:annotate")
    suspend fun images(
        @Body request: ImagesRequest,
        @Query("key") key: String = BuildConfig.VISION_API_KEY
    ): ImagesResponse
}
