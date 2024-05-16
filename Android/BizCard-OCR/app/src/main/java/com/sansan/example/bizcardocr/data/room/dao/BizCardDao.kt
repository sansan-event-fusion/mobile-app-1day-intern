package com.sansan.example.bizcardocr.data.room.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import com.sansan.example.bizcardocr.data.room.entites.BizCardEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface BizCardDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(bizCard: BizCardEntity): Long

    @Update
    suspend fun update(bizCard: BizCardEntity)

    @Delete
    suspend fun delete(bizCard: BizCardEntity)

    @Query("SELECT * from biz_card WHERE bizCardId = :bizCardId")
    fun get(bizCardId: Long): Flow<BizCardEntity>

    @Query("SELECT * from biz_card ORDER BY name ASC")
    fun getAll(): Flow<List<BizCardEntity>>
}