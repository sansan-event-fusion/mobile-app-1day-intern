package com.sansan.example.bizcardocr.data.room

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import com.sansan.example.bizcardocr.data.room.dao.BizCardDao
import com.sansan.example.bizcardocr.data.room.entites.BizCardEntity

@Database(entities = [BizCardEntity::class], version = 1, exportSchema = false)
@TypeConverters(DateConverter::class)
abstract class BizCardDatabase : RoomDatabase() {
    abstract fun bizCardDao(): BizCardDao
    companion object {
        @Volatile
        private var Instance: BizCardDatabase? = null

        fun getDatabase(context: Context): BizCardDatabase {
            return Instance ?: synchronized(this) {
                return Room.databaseBuilder(
                    context,
                    BizCardDatabase::class.java,
                    "bizcard_database"
                )
                    .build()
                    .also { Instance = it }
            }
        }
    }
}