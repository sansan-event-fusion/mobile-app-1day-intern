package com.sansan.example.bizcardocr.data.repository

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asSharedFlow

object CurrentBizCardRepository {

    private val currentBizCardImage: MutableStateFlow<ByteArray?> = MutableStateFlow(null)
    fun save(bizCardImage: ByteArray) {
        currentBizCardImage.value = bizCardImage
    }

    fun clear() {
        currentBizCardImage.value = null
    }

    fun getCurrentBizCardStream(): Flow<ByteArray?> = currentBizCardImage.asSharedFlow()
}