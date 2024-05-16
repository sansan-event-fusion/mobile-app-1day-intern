package com.sansan.example.bizcardocr.ui.detail

import android.graphics.BitmapFactory
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.sansan.example.bizcardocr.AppContainer
import com.sansan.example.bizcardocr.domain.repository.BizCardRepository
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import java.text.DateFormat
import java.text.SimpleDateFormat

class DetailViewModel(
    private val bizCardId: Long,
    private val bizCardRepository: BizCardRepository
) : ViewModel() {

    private val bizCardState = bizCardRepository
        .getBizCardStream(bizCardId)
        .map {
            DetailViewState(
                cardImage = BitmapFactory.decodeFile(it.cardImagePath),
                createdDateText = SimpleDateFormat.getDateInstance(DateFormat.DATE_FIELD)
                    .format(it.createdDate),
                name = it.name,
                company = it.company,
                tel = it.tel,
                email = it.email
            )
        }
        .stateIn(
            viewModelScope,
            started = SharingStarted.Eagerly,
            initialValue = DetailViewState(
                null,
                "----/--/--",
                "-",
                "-",
                "-",
                "-"
            )
        )

    val viewState: StateFlow<DetailViewState> = bizCardState

    class DetailViewModelFactory(
        private val bizCardId: Long,
        private val appContainer: AppContainer
    ) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            if (modelClass.isAssignableFrom(DetailViewModel::class.java)) {
                return DetailViewModel(bizCardId, appContainer.bizCardRepository) as T
            }
            throw IllegalArgumentException("Unknown ViewModel")
        }
    }
}

