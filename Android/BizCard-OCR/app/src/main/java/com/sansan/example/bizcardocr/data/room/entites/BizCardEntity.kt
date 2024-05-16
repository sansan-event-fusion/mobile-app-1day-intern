package com.sansan.example.bizcardocr.data.room.entites

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.Date

@Entity(tableName = "biz_card")
data class BizCardEntity(
    @PrimaryKey(autoGenerate = true)
    val bizCardId: Int,
    val createdDate: Date,
    val cardImagePath: String,
    val name: String = "",
    val departmentAndTitle: String = "",
    val tel: String = "",
    val email: String = "",
    val company: String = ""
)
