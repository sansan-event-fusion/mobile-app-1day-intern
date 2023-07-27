package com.sansan.example.bizcardocr.ui.result

import android.graphics.BitmapFactory
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.sansan.example.bizcardocr.data.network.googleapis.EntityAnnotation
import com.sansan.example.bizcardocr.data.network.googleapis.ImagesResponse
import com.sansan.example.bizcardocr.data.repository.BizCardRepository
import com.sansan.example.bizcardocr.data.repository.CurrentBizCardRepository
import com.sansan.example.bizcardocr.data.repository.OcrRepository
import com.sansan.example.bizcardocr.domain.model.BizCard
import com.sansan.example.bizcardocr.domain.model.OcrResult
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.firstOrNull
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.launch
import java.text.DateFormat
import java.text.SimpleDateFormat
import java.util.Date

class ResultViewModel : ViewModel() {

    private val _viewState: MutableStateFlow<ResultViewState> =
        MutableStateFlow(ResultViewState.InProgress(null))
    val viewState: StateFlow<ResultViewState> = _viewState.asStateFlow()

    private val _viewEvent: MutableSharedFlow<ResultViewEvent> = MutableSharedFlow()
    val viewEvent: SharedFlow<ResultViewEvent> = _viewEvent.asSharedFlow()

    private var currentBizCard: ByteArray? = null

    private val bizCardListRepository = BizCardRepository
    private val currentBizCardRepository = CurrentBizCardRepository
    private val ocrRepository = OcrRepository
    private val createAt = Date()

    init {
        viewModelScope.launch {
            currentBizCard = currentBizCardRepository.getCurrentBizCardStream().firstOrNull()
            if (currentBizCard == null) {
                _viewState.value = ResultViewState.Error(null)
            } else {
                val bitmap = BitmapFactory.decodeByteArray(
                    currentBizCard,
                    0,
                    currentBizCard!!.size
                )
                _viewState.value = ResultViewState.InProgress(bitmap)
                ocrRepository.ocrRequest(currentBizCard!!)
            }
        }

        viewModelScope.launch {
            ocrRepository
                .getOcrStream()
                .onEach { imageResponse ->
                    if (imageResponse != null) {
                        val bizCardInfo = parseOcrResult(imageResponse)
                        _viewState.value = ResultViewState.Success(
                            capturedCardImage = viewState.value.capturedCardImage,
                            createdDateText = SimpleDateFormat.getDateInstance(DateFormat.DATE_FIELD)
                                .format(createAt),
                            name = bizCardInfo?.personName ?: "",
                            company = bizCardInfo?.companyName ?: "",
                            tel = bizCardInfo?.tel ?: "",
                            email = bizCardInfo?.email ?: ""
                        )
                    } else {
                        _viewState.value = ResultViewState.Error(viewState.value.capturedCardImage)
                    }
                }
                .launchIn(viewModelScope)
        }
    }

    fun onRegisterButtonPressed(name: String, company: String, email: String, tel: String) {
        val state = viewState.value
        if (state is ResultViewState.Success) {
            viewModelScope.launch {
                bizCardListRepository.createBizCard(
                    BizCard(
                        bizCardId = 1,
                        cardImage = currentBizCard!!,
                        createdDate = createAt,
                        name = name,
                        email = email,
                        tel = tel,
                        company = company
                    )
                )
                _viewEvent.emit(ResultViewEvent.TRANSITION_TO_TOP)
            }
        }
    }

    fun onBackButtonPressed() {
        viewModelScope.launch {
            currentBizCardRepository.clear()
            _viewEvent.emit(ResultViewEvent.TRANSITION_TO_CAPTURE)
        }
    }

    private val regexFindCompany = """""".toRegex()
    private val regexEmail = """""".toRegex()
    private val regexTel = """""".toRegex()
    private val regexFindName =
        """^\p{InCJKUnifiedIdeographs}{1,3}\s?\p{InCJKUnifiedIdeographs}{1,3}$""".toRegex()
    private val regexMatchDepartmentPosition = """[部課任(会計|部長)]$""".toRegex()

    private fun parseOcrResult(response: ImagesResponse): OcrResult? {
        if (response.responses.isEmpty()) {
            return null
        }

        // 1番目のOCR結果のみ使用する
        val result = response.responses.first()
        return result.textAnnotations?.let(this::parseTextAnnotation)
    }

    private fun parseTextAnnotation(textAnnotation: List<EntityAnnotation>): OcrResult {
        var personName: String? = null
        var companyName: String? = null
        var email: String? = null
        var tel: String? = null

        val allTexts = textAnnotation.first().description.split("\n")

        allTexts.map {
            when {
                isPersonName(it) -> personName = getPersonName(it)
            }
        }
        return OcrResult(personName, email, tel, companyName)
    }

    private fun isPersonName(text: String): Boolean =
        regexFindName.containsMatchIn(text) && !regexMatchDepartmentPosition.containsMatchIn(text)

    // 1行まるまる氏名が来る想定(名刺の種類に応じて適宜見直す)
    private fun getPersonName(text: String): String? = text
}