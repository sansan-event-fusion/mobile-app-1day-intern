package com.sansan.example.bizcardocr.ui.detail

import android.graphics.Bitmap

data class DetailViewState(
    val cardImage: Bitmap?,
    val createdDateText: String,
    val name: String,
    val company: String,
    val email: String,
    val tel: String
)