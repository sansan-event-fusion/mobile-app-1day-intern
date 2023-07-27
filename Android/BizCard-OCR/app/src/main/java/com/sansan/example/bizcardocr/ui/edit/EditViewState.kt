package com.sansan.example.bizcardocr.ui.edit

import android.graphics.Bitmap

data class EditViewState(
    val cardImage: Bitmap?,
    val createdDateText: String,
    val name: String,
    val company: String,
    val email: String,
    val tel: String
)