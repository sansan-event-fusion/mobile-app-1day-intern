package com.sansan.example.bizcardocr.data.network

import com.sansan.example.bizcardocr.BuildConfig
import com.sansan.example.bizcardocr.data.network.googleapis.VisionApi
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

object ApiProvider {

    val visionApi by lazy { visionApi() }

    private fun visionApi(): VisionApi =
        provideVisionApiBuilder().create(VisionApi::class.java)

    private fun provideVisionApiBuilder() =
        Retrofit.Builder()
            .baseUrl(BuildConfig.VISION_API_URL)
            .client(provideOkHttpClient(provideLoggingInterceptor()))
            .addConverterFactory(GsonConverterFactory.create())
            .build()

    private fun provideOkHttpClient(interceptor: HttpLoggingInterceptor): OkHttpClient {
        val builder = OkHttpClient.Builder()
        builder.addInterceptor(interceptor)
        return builder.build()
    }

    private fun provideLoggingInterceptor(): HttpLoggingInterceptor {
        val interceptor = HttpLoggingInterceptor()
        interceptor.level = HttpLoggingInterceptor.Level.BODY
        return interceptor
    }
}
