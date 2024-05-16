package com.sansan.example.bizcardocr.ui.edit

import android.graphics.Bitmap
import com.sansan.example.bizcardocr.ui.CardFormState

data class EditViewState(
    val cardImage: Bitmap?,
    val createdDateText: String,
    val cardForm: CardFormState
)