package com.sansan.example.bizcardocr

import android.content.Context
import com.sansan.example.bizcardocr.data.repository.BizCardRepositoryImpl
import com.sansan.example.bizcardocr.data.room.BizCardDatabase
import com.sansan.example.bizcardocr.domain.repository.BizCardRepository

interface AppContainer {
    val bizCardRepository: BizCardRepository
}

class AppDataContainer(private val context: Context) : AppContainer {
    override val bizCardRepository: BizCardRepository by lazy {
        val dao = BizCardDatabase.getDatabase(context).bizCardDao()
        BizCardRepositoryImpl(context, dao)
    }
}