package com.sansan.example.bizcardocr.domain.model

import java.util.Date

/**
 * 名刺情報を表すクラス
 * @property bizCardId 名刺ID
 * @property createdDate 作成日
 * @property cardImagePath 名刺画像のパス
 * @property name 名前
 * @property departmentAndTitle 部署と役職
 * @property tel 電話番号
 * @property email メールアドレス
 * @property company 会社名
 */
data class BizCard(
    val bizCardId: Long,
    val createdDate: Date,
    val cardImagePath: String,
    val name: String = "",
    val departmentAndTitle: String = "",
    val tel: String = "",
    val email: String = "",
    val company: String = ""
)