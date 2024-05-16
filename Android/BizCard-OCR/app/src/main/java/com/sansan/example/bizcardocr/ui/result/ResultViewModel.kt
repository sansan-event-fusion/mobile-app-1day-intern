package com.sansan.example.bizcardocr.ui.result

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
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import java.text.DateFormat
import java.text.SimpleDateFormat
import java.util.Date

class ResultViewModel(
    private val bizCardRepository: BizCardRepository,
    private val targetFilePath: String
) : ViewModel() {

    private val cardImage = BitmapFactory.decodeFile(targetFilePath)
    private val createdAtText =
        SimpleDateFormat.getDateInstance(DateFormat.DATE_FIELD).format(Date())
    private val cardFormState = MutableStateFlow(CardFormState("", "", "", ""))
    private val isButtonEnabledState = MutableStateFlow(false)
    private val progressState = MutableStateFlow(OCRProgress.INIT)

    val viewState: StateFlow<ResultViewState> = combine(
        cardFormState,
        isButtonEnabledState,
        progressState
    ) { inputState, isButtonEnabled, progressState ->
        ResultViewState(
            capturedCardImage = cardImage,
            createdDateText = createdAtText,
            cardForm = inputState,
            isButtonEnabled = isButtonEnabled,
            progress = progressState
        )
    }.stateIn(
        viewModelScope,
        started = SharingStarted.Eagerly,
        initialValue = ResultViewState(
            capturedCardImage = null,
            createdDateText = "----/--/--",
            cardForm = CardFormState("", "", "", ""),
            isButtonEnabled = false,
            progress = OCRProgress.INIT
        )
    )

    init {
        viewModelScope.launch {
            progressState.value = OCRProgress.IN_PROGRESS
            bizCardRepository.getBizCard(targetFilePath).let { result ->
                result.onSuccess {
                    cardFormState.value = CardFormState(it.name, it.company, it.email, it.tel)
                    progressState.value = OCRProgress.SUCCESS
                    isButtonEnabledState.value = true
                }.onFailure {
                    progressState.value = OCRProgress.ERROR
                }
            }
        }
    }

    private val _viewEvent: MutableSharedFlow<ResultViewEvent> = MutableSharedFlow()
    val viewEvent: SharedFlow<ResultViewEvent> = _viewEvent.asSharedFlow()

    fun onRegisterButtonPressed(
        name: String,
        company: String,
        email: String,
        tel: String
    ) {
        viewModelScope.launch {
            bizCardRepository.createBizCard(
                BizCard(
                    bizCardId = 0,
                    cardImagePath = targetFilePath,
                    createdDate = Date(),
                    name = name,
                    company = company,
                    email = email,
                    tel = tel,
                )
            )
            _viewEvent.emit(ResultViewEvent.TRANSITION_TO_TOP)
        }
    }

    fun onBackButtonPressed() {
        viewModelScope.launch {
            _viewEvent.emit(ResultViewEvent.TRANSITION_TO_CAPTURE)
        }
    }

    class ResultViewModelFactory(
        private val appContainer: AppContainer,
        private val targetFilePath: String
    ) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            if (modelClass.isAssignableFrom(ResultViewModel::class.java)) {
                return ResultViewModel(appContainer.bizCardRepository, targetFilePath) as T
            }
            throw IllegalArgumentException("Unknown ViewModel")
        }
    }
}