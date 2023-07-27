package com.sansan.example.bizcardocr.ui.result

import android.graphics.Bitmap

sealed interface ResultViewState {

    val capturedCardImage: Bitmap?

    data class InProgress(
        override val capturedCardImage: Bitmap?
    ) : ResultViewState

    data class Error(
        override val capturedCardImage: Bitmap?
    ) : ResultViewState

    data class Success(
        override val capturedCardImage: Bitmap?,
        val createdDateText: String,
        val name: String,
        val company: String,
        val tel: String,
        val email: String
    ) : ResultViewState
}