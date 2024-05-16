package com.sansan.example.bizcardocr.ui.result

import android.graphics.Bitmap
import com.sansan.example.bizcardocr.ui.CardFormState

data class ResultViewState(
    val capturedCardImage: Bitmap?,
    val createdDateText: String,
    val cardForm: CardFormState,
    val isButtonEnabled: Boolean,
    val progress: OCRProgress
)

enum class OCRProgress {
    INIT, IN_PROGRESS, ERROR, SUCCESS
}