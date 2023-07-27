package com.sansan.example.bizcardocr.ui.main

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.sansan.example.bizcardocr.data.repository.BizCardRepository
import com.sansan.example.bizcardocr.utility.createBitmapFromJpeg
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.launch
import java.util.Calendar

class MainViewModel : ViewModel() {

    private val _viewState: MutableStateFlow<MainViewState> =
        MutableStateFlow(MainViewState(listOf()))
    val viewState = _viewState.asStateFlow()

    private val _viewEvent: MutableSharedFlow<MainViewEvent> = MutableSharedFlow()
    val viewEvent: SharedFlow<MainViewEvent> = _viewEvent.asSharedFlow()

    private val bizCardRepository = BizCardRepository

    init {
        bizCardRepository
            .getBizCardListStream()
            .onEach {
                val newState = MainViewState(
                    sequence {
                        val itemGroup = it.groupBy {
                            val calender = Calendar.getInstance().apply {
                                time = it.createdDate
                            }
                            "${calender.get(Calendar.YEAR)}/${
                                String.format(
                                    "%02d",
                                    calender.get(Calendar.MONTH) + 1
                                )
                            }"
                        }
                        itemGroup.forEach { item ->
                            yield(CardListItem.Section(item.key))
                            item.value.forEach {
                                yield(
                                    CardListItem.BizCard(
                                        id = it.bizCardId,
                                        name = it.name,
                                        company = it.company,
                                        cardImage = it.cardImage.createBitmapFromJpeg()
                                    )
                                )
                            }
                        }

                    }.toList()

                )
                _viewState.value = newState
            }
            .launchIn(viewModelScope)
    }

    fun onListItemClicked(bizCard: CardListItem) {
        viewModelScope.launch {
            if (bizCard is CardListItem.BizCard) {
                _viewEvent.emit(MainViewEvent.TransitionToDetail(bizCard.id))
            }
        }
    }
}