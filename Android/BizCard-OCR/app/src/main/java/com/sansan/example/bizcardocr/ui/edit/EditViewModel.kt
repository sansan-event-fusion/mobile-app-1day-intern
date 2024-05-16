package com.sansan.example.bizcardocr.ui.edit

import android.graphics.BitmapFactory
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.sansan.example.bizcardocr.AppContainer
import com.sansan.example.bizcardocr.domain.model.BizCard
import com.sansan.example.bizcardocr.domain.repository.BizCardRepository
import com.sansan.example.bizcardocr.ui.CardFormState
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import java.text.DateFormat
import java.text.SimpleDateFormat

class EditViewModel(
    private val bizCardId: Long,
    private val bizCardRepository: BizCardRepository
) : ViewModel() {

    private val cardFormState = MutableStateFlow(CardFormState("", "", "", ""))
    private val bizCardState = bizCardRepository.getBizCardStream(bizCardId)

    init {
        viewModelScope.launch {
            cardFormState.value = bizCardState.map {
                CardFormState(it.name, it.company, it.email, it.tel)
            }.first()
        }
    }

    val viewState: StateFlow<EditViewState> = combine(
        bizCardState,
        cardFormState,
    ) { bizCard, cardForm ->
        EditViewState(
            cardImage = bizCard.cardImagePath.let { BitmapFactory.decodeFile(it) },
            createdDateText = SimpleDateFormat.getDateInstance(DateFormat.DATE_FIELD)
                .format(bizCard.createdDate),
            cardForm = cardForm
        )
    }.stateIn(
        viewModelScope,
        started = SharingStarted.Eagerly,
        initialValue = EditViewState(
            cardImage = null,
            createdDateText = "----/--/--",
            cardForm = CardFormState("", "", "", "")
        )
    )

    private val _viewEvent: MutableSharedFlow<EditViewEvent> = MutableSharedFlow()
    val viewEvent: SharedFlow<EditViewEvent> = _viewEvent.asSharedFlow()

    fun onRegisterButtonPressed(name: String, email: String, tel: String, company: String) {
        viewModelScope.launch {
            val bizCard = bizCardState.first()
            val newBizCard = BizCard(
                bizCardId = bizCard.bizCardId,
                cardImagePath = bizCard.cardImagePath,
                createdDate = bizCard.createdDate,
                name = name,
                company = company,
                email = email,
                tel = tel
            )
            bizCardRepository.updateCard(newBizCard)
            _viewEvent.emit(EditViewEvent.TRANSITION_TO_HOME)
        }
    }

    class EditViewModelFactory(
        private val bizCardId: Long,
        private val appContainer: AppContainer
    ) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            if (modelClass.isAssignableFrom(EditViewModel::class.java)) {
                return EditViewModel(bizCardId, appContainer.bizCardRepository) as T
            }
            throw IllegalArgumentException("Unknown ViewModel")
        }
    }

}