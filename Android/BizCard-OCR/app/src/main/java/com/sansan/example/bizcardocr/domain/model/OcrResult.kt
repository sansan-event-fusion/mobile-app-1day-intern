package com.sansan.example.bizcardocr.domain.model

data class OcrResult(
    val personName: String?,
    val email: String?,
    val tel: String?,
    val companyName: String?
)
