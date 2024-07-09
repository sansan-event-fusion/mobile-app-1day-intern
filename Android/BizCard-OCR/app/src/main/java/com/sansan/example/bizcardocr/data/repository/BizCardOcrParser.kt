package com.sansan.example.bizcardocr.data.repository

import com.sansan.example.bizcardocr.data.network.googleapis.EntityAnnotation
import com.sansan.example.bizcardocr.data.network.googleapis.ImagesResponse

// FIXME: 名刺や表示項目に合わせて下記内容は適宜見直してください。
class BizCardOcrParser(
    response: ImagesResponse
) {
    var personName: String? = null
    var companyName: String? = null
    var email: String? = null
    var tel: String? = null
    var departmentAndTitle: String? = null

    /**
     * 1day向けの正規表現
     */
    private val regexFindCompany = """株式会社""".toRegex()
    private val regexEmail = """E-?mail\s?([\d.a-z\-]+@[\d.a-z]+)""".toRegex()
    private val regexTel = """TEL\s?(\d{2,3}-\d{4}-\d{4})""".toRegex()
    private val regexFindName =
        """^\p{InCJKUnifiedIdeographs}{1,3}\s?\p{InCJKUnifiedIdeographs}{1,3}$""".toRegex()
    private val regexMatchDepartmentPosition = """[部課任(会計|部長)]$""".toRegex()

    init {
        // 1番目のOCR結果のみ使用する
        val result = response.responses.first()
        result.textAnnotations?.let(this::parseTextAnnotation)
    }

    private fun parseTextAnnotation(textAnnotation: List<EntityAnnotation>) {

        val allTexts = textAnnotation.first().description.split("\n")

        allTexts.map {
            when {
                isCompanyName(it) -> companyName = getCompanyName(it)
                isEmail(it) -> email = getEmail(it)
                isTel(it) -> tel = getTel(it)
                isPersonName(it) -> personName = getPersonName(it)
                isDepartmentAndTitle(it) -> departmentAndTitle = getDepartmentAndTitle(it)
            }
        }
    }

    private fun isCompanyName(text: String): Boolean =
        regexFindCompany.containsMatchIn(text)

    // 1行まるまる会社名が来る想定(名刺の種類に応じて適宜見直す)
    private fun getCompanyName(text: String): String? = text

    private fun isEmail(text: String): Boolean =
        regexEmail.containsMatchIn(text)

    private fun getEmail(text: String): String? =
        regexEmail.find(text)?.groupValues?.getOrNull(1)

    private fun isTel(text: String): Boolean =
        regexTel.containsMatchIn(text)

    private fun getTel(text: String): String? =
        regexTel.find(text)?.groupValues?.getOrNull(1)

    private fun isPersonName(text: String): Boolean =
        regexFindName.containsMatchIn(text) && !regexMatchDepartmentPosition.containsMatchIn(text)

    private fun isDepartmentAndTitle(text: String): Boolean =
        regexMatchDepartmentPosition.containsMatchIn(text)

    private fun getDepartmentAndTitle(text: String) = text

    // 1行まるまる氏名が来る想定(名刺の種類に応じて適宜見直す)
    private fun getPersonName(text: String): String? = text
}
