package com.sansan.example.bizcardocr.ui.main

import android.graphics.Bitmap

data class MainViewState(
    val appBarState: AppBarState,
    val cardList: List<CardListItem>
)

sealed interface AppBarState {
    data class Default(val showOptionMenu: Boolean) : AppBarState
    data class Search(val query: String) : AppBarState
}

enum class MainAppBarMenu {
    SORT_BY_DATE_ASC,
    SORT_BY_DATE_DESC,
}

sealed interface CardListItem {
    data class BizCard(
        val id: Long,
        val name: String,
        val company: String,
        val departmentAndTitle: String,
        val cardImage: Bitmap
    ) : CardListItem

    data class Section(
        val sectionYear: String,
        val sectionMonth: String,
        val sectionDay: String
    ) : CardListItem
}
