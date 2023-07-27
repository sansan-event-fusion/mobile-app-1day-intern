package com.sansan.example.bizcardocr.ui.edit

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.sansan.example.bizcardocr.data.repository.BizCardRepository
import com.sansan.example.bizcardocr.domain.model.BizCard
import com.sansan.example.bizcardocr.utility.createBitmapFromJpeg
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.launch
import java.text.DateFormat
import java.text.SimpleDateFormat

class EditViewModel(private val bizCardId: Long) : ViewModel() {

    private val bizCardRepository = BizCardRepository

    private val _viewState: MutableStateFlow<EditViewState> = MutableStateFlow(
        EditViewState(
            cardImage = null,
            createdDateText = "----/--/--",
            name = "-",
            company = "-",
            email = "-",
            tel = "-"
        )
    )

    val viewState = _viewState.asStateFlow()

    private val _viewEvent: MutableSharedFlow<EditViewEvent> = MutableSharedFlow()
    val viewEvent: SharedFlow<EditViewEvent> = _viewEvent.asSharedFlow()

    init {
        bizCardRepository
            .getBizCardStream(bizCardId)
            .onEach {
                _viewState.value = EditViewState(
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

    fun onRegisterButtonPressed(name: String, email: String, tel: String, company: String) {
        viewModelScope.launch {
            val oldBizCard = bizCardRepository.getBizCardStream(bizCardId).first()
            val newBizCard = BizCard(
                bizCardId = bizCardId,
                cardImage = oldBizCard.cardImage,
                createdDate = oldBizCard.createdDate,
                name = name,
                company = company,
                email = email,
                tel = tel
            )
            bizCardRepository.updateCard(newBizCard)
            _viewEvent.emit(EditViewEvent.TRANSITION_TO_HOME)
        }
    }

    class EditViewModelFactory(private val bizCardId: Long) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            if (modelClass.isAssignableFrom(EditViewModel::class.java)) {
                return EditViewModel(bizCardId) as T
            }
            throw IllegalArgumentException("Unknown ViewModel")
        }
    }

}