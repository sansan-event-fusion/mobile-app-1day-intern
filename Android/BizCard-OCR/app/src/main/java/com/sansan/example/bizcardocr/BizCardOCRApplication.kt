package com.sansan.example.bizcardocr

import android.app.Application

class BizCardOCRApplication : Application() {

    lateinit var container: AppContainer

    override fun onCreate() {
        super.onCreate()
        container = AppDataContainer(this)
    }
}