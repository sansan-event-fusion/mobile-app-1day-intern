package com.sansan.example.bizcardocr.domain.usecase

import com.sansan.example.bizcardocr.data.network.googleapis.AnnotateImageResponse
import com.sansan.example.bizcardocr.data.network.googleapis.EntityAnnotation
import com.sansan.example.bizcardocr.data.network.googleapis.ImagesResponse
import com.sansan.example.bizcardocr.data.repository.BizCardOcrParser
import org.junit.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull

class BizCardOcrParserTest {
    @Test
    fun parseOcrResultCase1() {
        val testDescription = "INADA\nいなだ出版株式会社\n監查部部長\n“宗照\n瀬津 宗昭\nT150-5569\n東京都登町区西原99-92 いなだビル\nTEL 033-3540-9171\nFAX 033-3540-9172\nMOBILE 096-1199-7654\nE-mail inada-syuppan@inds.fd.df\nSITE http://inada-syuppan.wik\n。\n"
        val response = createResponse(testDescription)
        val result = BizCardOcrParser(response)

        assertNotNull(result, "オブジェクトの生成に失敗")

        // 会社名
        assertEquals("いなだ出版株式会社" , result.companyName,"会社名のパースに失敗")
        // 氏名
        assertEquals("瀬津 宗昭", result.personName,"氏名のパースに失敗")
        // 電話番号(FAX, MOBILEを誤検知しないかどうかも含めて確認)
        assertEquals("033-3540-9171", result.tel,"電話番号のパースに失敗")
        // Email
        assertEquals("inada-syuppan@inds.fd.df", result.email,"メールアドレスのパースに失敗")
    }

    @Test
    fun parseOcrResultCase2() {
        val testDescription = "エンジニアリングサービスユニット\nサービス主任\n手島千枝\n〒150-0001\n東京都渋谷区神宮前5-52-2 青山オーバルビル13F\nTEL 03-6758-0033\nFAX 03-3409-3133\nMOBILE 090-1234-5678\nE-mail dummy092@sansan.co.jp\nSITE http://jp.corp-sansan.com/\nエイトバンク銀行株式会社\n"

        val response = createResponse(testDescription)
        val result = BizCardOcrParser(response)

        assertNotNull(result, "オブジェクトの生成に失敗")

        // 会社名
        assertEquals("エイトバンク銀行株式会社" , result.companyName,"会社名のパースに失敗")
        // 氏名
        assertEquals("手島千枝", result.personName,"氏名のパースに失敗")
        // 電話番号(FAX, MOBILEを誤検知しないかどうかも含めて確認)
        assertEquals("03-6758-0033", result.tel,"電話番号のパースに失敗")
        // Email
        assertEquals("dummy092@sansan.co.jp", result.email,"メールアドレスのパースに失敗")
    }

    @Test
    fun parseOcrResultCase3() {
        val testDescription = "LEANグローバル株式会社\n營業本部\n部長補佐\n瀬長梨花\n〒150-0001 東京都渋谷区神宮前5-52-2\n青山才一代LED 13F\nTEL 03-6758-0033\nFAX 03-3409-3133\nMOBILE 090-1234-5678\nE-mail dummy129@sansan.co.jp\nSITE http://jp.corp-sansan.com/\n"
        val response = createResponse(testDescription)
        val result = BizCardOcrParser(response)

        assertNotNull(result, "オブジェクトの生成に失敗")

        // 会社名
        assertEquals("LEANグローバル株式会社" , result.companyName,"会社名のパースに失敗")
        // 氏名
        assertEquals("瀬長梨花", result.personName,"氏名のパースに失敗")
        // 電話番号(FAX, MOBILEを誤検知しないかどうかも含めて確認)
        assertEquals("03-6758-0033", result.tel,"電話番号のパースに失敗")
        // Email
        assertEquals("dummy129@sansan.co.jp", result.email,"メールアドレスのパースに失敗")
    }

    private fun createResponse(description: String): ImagesResponse {
        val textAnnotation = EntityAnnotation("en", description)
        val annotateImagesResponse = AnnotateImageResponse(listOf(textAnnotation), null)
        return ImagesResponse(listOf(annotateImagesResponse))
    }
}
