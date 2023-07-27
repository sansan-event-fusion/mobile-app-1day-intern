package com.sansan.example.bizcardocr.ui.detail

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.sansan.example.bizcardocr.data.repository.BizCardRepository
import com.sansan.example.bizcardocr.utility.createBitmapFromJpeg
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import java.text.DateFormat
import java.text.SimpleDateFormat

class DetailViewModel(private val bizCardId: Long) : ViewModel() {

    private val bizCardRepository = BizCardRepository

    private val _viewState: MutableStateFlow<DetailViewState> = MutableStateFlow(
        DetailViewState(
            null,
            "----/--/--",
            "-",
            "-",
            "-",
            "-"
        )
    )

    val viewState: StateFlow<DetailViewState> = _viewState.asStateFlow()

    init {
        bizCardRepository
            .getBizCardStream(bizCardId)
            .onEach {
                _viewState.value = DetailViewState(
                    cardImage = it.cardImage.createBitmapFromJpeg(),
                    createdDateText = SimpleDateFormat.getDateInstance(DateFormat.DATE_FIELD)
                        .format(it.createdDate),
                    name = it.name,
                    company = it.company,
                    tel = it.tel,
                    email = it.email
                )
            }
            .launchIn(viewModelScope)
    }

    class DetailViewModelFactory(private val bizCardId: Long) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            if (modelClass.isAssignableFrom(DetailViewModel::class.java)) {
                return DetailViewModel(bizCardId) as T
            }
            throw IllegalArgumentException("Unknown ViewModel")
        }
    }
}

