package com.sansan.example.bizcardocr.domain.model

import java.util.Date

class BizCard(
    val bizCardId: Long,
    val createdDate: Date,
    val cardImage: ByteArray,
    val name: String = "",
    val tel: String = "",
    val email: String = "",
    val company: String = ""
)