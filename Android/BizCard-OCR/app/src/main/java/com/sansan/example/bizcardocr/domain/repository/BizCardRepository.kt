package com.sansan.example.bizcardocr.domain.repository

import com.sansan.example.bizcardocr.domain.model.BizCard
import kotlinx.coroutines.flow.Flow

interface BizCardRepository {

    /**
     * 名刺情報を保存する
     */
    suspend fun createBizCard(bizCard: BizCard)

    /**
     * 名刺情報を更新する
     */
    suspend fun updateCard(bizCardInfo: BizCard)

    /**
     * 名刺画像から名刺情報を保存する
     */
    suspend fun getBizCard(bizCardImageFilePath: String): Result<BizCard>

    /**
     * 指定されたIDの名刺情報を取得する
     */
    fun getBizCardStream(bizCardId: Long): Flow<BizCard>

    /**
     * 名刺一覧を取得する
     */
    fun getBizCardsStream(): Flow<List<BizCard>>
}