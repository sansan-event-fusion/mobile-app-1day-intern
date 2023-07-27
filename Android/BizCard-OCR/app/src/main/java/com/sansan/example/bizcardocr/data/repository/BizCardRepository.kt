package com.sansan.example.bizcardocr.data.repository

import com.sansan.example.bizcardocr.domain.model.BizCard
import kotlinx.coroutines.channels.BufferOverflow
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.map

object BizCardRepository {

    private val bizCardList: MutableList<BizCard> = mutableListOf()
    private val bizCardStream: MutableSharedFlow<List<BizCard>> = MutableSharedFlow(
        replay = 1,
        extraBufferCapacity = 1,
        onBufferOverflow = BufferOverflow.DROP_OLDEST
    )

    suspend fun createBizCard(bizCardInfo: BizCard) {
        val lastId = bizCardList.lastOrNull()?.bizCardId ?: 0
        val newBizCard = BizCard(
            bizCardId = lastId + 1,
            cardImage = bizCardInfo.cardImage,
            createdDate = bizCardInfo.createdDate,
            name = bizCardInfo.name,
            company = bizCardInfo.company,
            email = bizCardInfo.email,
            tel = bizCardInfo.tel
        )
        bizCardList.add(newBizCard)
        bizCardStream.emit(bizCardList)
    }

    suspend fun updateCard(bizCardInfo: BizCard) {
        val index = bizCardList.indexOfFirst { it.bizCardId == bizCardInfo.bizCardId }
        bizCardList.removeAt(index)
        bizCardList.add(index, bizCardInfo)
        bizCardStream.emit(bizCardList)
    }

    fun getBizCardStream(bizCardId: Long): Flow<BizCard> {
        return bizCardStream.asSharedFlow()
            .map { it.first { bizCard -> bizCard.bizCardId == bizCardId } }
    }

    fun getBizCardListStream(): Flow<List<BizCard>> {
        return bizCardStream.asSharedFlow()
    }
}