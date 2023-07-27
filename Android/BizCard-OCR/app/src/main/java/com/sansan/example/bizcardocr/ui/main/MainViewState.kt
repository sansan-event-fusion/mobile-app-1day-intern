package com.sansan.example.bizcardocr.ui.main

import android.graphics.Bitmap

data class MainViewState(val cardList: List<CardListItem>)

sealed interface CardListItem {
    data class BizCard(
        val id: Long,
        val name: String,
        val company: String,
        val cardImage: Bitmap
    ) : CardListItem

    data class Section(
        val sectionTitle: String
    ) : CardListItem
}
