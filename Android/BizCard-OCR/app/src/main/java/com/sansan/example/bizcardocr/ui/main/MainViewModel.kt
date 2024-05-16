package com.sansan.example.bizcardocr.ui.main

import android.graphics.BitmapFactory
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.sansan.example.bizcardocr.AppContainer
import com.sansan.example.bizcardocr.domain.repository.BizCardRepository
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import java.util.Calendar

class MainViewModel(
    private val bizCardRepository: BizCardRepository
) : ViewModel() {

    private val _viewEvent: MutableSharedFlow<MainViewEvent> = MutableSharedFlow()
    val viewEvent: SharedFlow<MainViewEvent> = _viewEvent.asSharedFlow()

    private val appBarState = MutableStateFlow<AppBarState>(AppBarState.Default(false))
    private val bizCardState: StateFlow<List<CardListItem>> = bizCardRepository
        .getBizCardsStream()
        .map {
            it.groupBy { bizCard ->
                val calendar = Calendar.getInstance().apply {
                    time = bizCard.createdDate
                }
                CardListItem.Section(
                    calendar.get(Calendar.YEAR).toString(),
                    String.format("%02d", calendar.get(Calendar.MONTH)),
                    String.format("%02d", calendar.get(Calendar.DATE))
                )
            }.flatMap { entry ->
                val section = listOf(entry.key)
                val bizCards = entry.value.map { bizCard ->
                    CardListItem.BizCard(
                        id = bizCard.bizCardId,
                        name = bizCard.name,
                        company = bizCard.company,
                        departmentAndTitle = bizCard.departmentAndTitle,
                        cardImage = BitmapFactory.decodeFile(bizCard.cardImagePath)
                    )
                }
                section + bizCards
            }
        }
        .stateIn(viewModelScope, started = SharingStarted.Eagerly, initialValue = emptyList())

    val viewState = combine(
        appBarState,
        bizCardState
    ) { appBarState, cardList ->
        MainViewState(
            appBarState = appBarState,
            cardList = cardList
        )
    }.stateIn(
        viewModelScope,
        started = SharingStarted.Eagerly,
        initialValue = MainViewState(AppBarState.Default(false), emptyList())
    )

    /**
     * 名刺がクリックされたときの処理
     * @param bizCard 名刺
     */
    fun onListItemClicked(bizCard: CardListItem) {
        viewModelScope.launch {
            if (bizCard is CardListItem.BizCard) {
                _viewEvent.emit(MainViewEvent.TransitionToDetail(bizCard.id))
            }
        }
    }

    /**
     * カメラ画面に遷移する
     */
    fun launchCamera() {
        viewModelScope.launch {
            _viewEvent.emit(MainViewEvent.TransitionToCamera)
        }
    }

    /**
     * 検索バーを表示する
     */
    fun showSearchAppBar() {
        appBarState.value = AppBarState.Search("")
    }

    /**
     * オプションメニューを表示する
     */
    fun showMenu() {
        appBarState.value = AppBarState.Default(true)
    }

    /**
     * 選択されたオプションメニューによってソート順を変更する
     * @param item 選択されたオプションメニュー
     */
    fun applyOption(item: MainAppBarMenu) {
        // TODO: ソート処理を実装してみましょう
        when (item) {
            MainAppBarMenu.SORT_BY_DATE_ASC -> {
                appBarState.value = AppBarState.Default(false)
            }

            MainAppBarMenu.SORT_BY_DATE_DESC -> {
                appBarState.value = AppBarState.Default(false)
            }
        }
    }

    /**
     * デフォルトのアプリバーを表示する
     */
    fun showDefaultAppBar() {
        appBarState.value = AppBarState.Default(false)
    }

    /**
     * 検索クエリを変更する
     * @param query 検索クエリ
     */
    fun queryChange(query: String) {
        // TODO: 検索処理を実装してみましょう
        appBarState.value = AppBarState.Search(query)
    }

    /**
     * オプションメニューを閉じる
     */
    fun dismissOptionMenu() {
        appBarState.value = AppBarState.Default(false)
    }

    class MainViewModelFactory(
        private val appContainer: AppContainer
    ) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            if (modelClass.isAssignableFrom(MainViewModel::class.java)) {
                return MainViewModel(appContainer.bizCardRepository) as T
            }
            throw IllegalArgumentException("Unknown ViewModel")
        }
    }
}