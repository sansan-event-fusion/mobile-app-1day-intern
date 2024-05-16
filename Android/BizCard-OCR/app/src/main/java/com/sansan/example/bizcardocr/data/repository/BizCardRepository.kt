package com.sansan.example.bizcardocr.data.repository

import android.content.Context
import android.util.Base64
import android.util.Base64OutputStream
import com.sansan.example.bizcardocr.data.network.ApiProvider
import com.sansan.example.bizcardocr.data.network.googleapis.Feature
import com.sansan.example.bizcardocr.data.network.googleapis.ImagesRequest
import com.sansan.example.bizcardocr.data.room.dao.BizCardDao
import com.sansan.example.bizcardocr.data.room.entites.BizCardEntity
import com.sansan.example.bizcardocr.domain.model.BizCard
import com.sansan.example.bizcardocr.domain.repository.BizCardRepository
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream
import java.io.File
import java.util.Date

class BizCardRepositoryImpl(
    private val context: Context,
    private val bizCardDao: BizCardDao
) : BizCardRepository {

    override suspend fun createBizCard(bizCard: BizCard) {
        withContext(Dispatchers.IO) {
            bizCardDao.insert(bizCard.toEntity())
        }
    }

    override suspend fun updateCard(bizCardInfo: BizCard) {
        withContext(Dispatchers.IO) {
            bizCardDao.update(bizCardInfo.toEntity())
        }
    }

    override suspend fun getBizCard(bizCardImageFilePath: String): Result<BizCard> {
        return withContext(Dispatchers.IO) {
            // 画像をBase64にエンコード
            val bizCardImageFile = File(bizCardImageFilePath)
            val cardImageSource = ByteArrayOutputStream().use { outputStream ->
                Base64OutputStream(outputStream, Base64.DEFAULT).use { base64FilterStream ->
                    bizCardImageFile.inputStream().use { inputStream ->
                        inputStream.copyTo(base64FilterStream)
                    }
                }
                return@use outputStream.toString()
            }

            val request = ImagesRequest.createSingleRequest(
                cardImageSource,
                Feature.Type.DOCUMENT_TEXT_DETECTION
            )

            val bizCard = runCatching { ApiProvider.visionApi.images(request) }
                .map {
                    val parser = BizCardOcrParser(it)
                    // 主キーが0の時にRoomは値未設定として扱いIDを自動付与する
                    BizCard(
                        bizCardId = 0,
                        createdDate = Date(),
                        cardImagePath = bizCardImageFilePath,
                        name = parser.personName ?: "",
                        departmentAndTitle = parser.departmentAndTitle ?: "",
                        tel = parser.tel ?: "",
                        email = parser.email ?: "",
                        company = parser.companyName ?: ""
                    )
                }
            return@withContext bizCard
        }
    }

    override fun getBizCardStream(bizCardId: Long): Flow<BizCard> {
        return bizCardDao
            .get(bizCardId)
            .map { it.toBizCard() }
    }

    override fun getBizCardsStream(): Flow<List<BizCard>> {
        return bizCardDao
            .getAll()
            .map { stream ->
                stream.map { list ->
                    list.toBizCard()
                }
            }
    }

    private fun BizCard.toEntity(): BizCardEntity {
        return BizCardEntity(
            bizCardId = bizCardId.toInt(),
            createdDate = createdDate,
            cardImagePath = cardImagePath,
            name = name,
            departmentAndTitle = departmentAndTitle,
            tel = tel,
            email = email,
            company = company
        )
    }

    private fun BizCardEntity.toBizCard(): BizCard {
        return BizCard(
            bizCardId = bizCardId.toLong(),
            createdDate = createdDate,
            cardImagePath = cardImagePath,
            name = name,
            departmentAndTitle = departmentAndTitle,
            tel = tel,
            email = email,
            company = company
        )
    }
}