package com.sansan.example.bizcardocr.ui.camera

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.sansan.example.bizcardocr.data.repository.CurrentBizCardRepository
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.launch

class CameraViewModel : ViewModel() {

    private val currentBIzCardRepository = CurrentBizCardRepository

    private val _transactionEvent: MutableSharedFlow<CameraViewEvent> = MutableSharedFlow()
    val transactionEvent: SharedFlow<CameraViewEvent> = _transactionEvent.asSharedFlow()

    fun onTakePictureSuccess(bizCardImage: ByteArray) {
        currentBIzCardRepository.save(bizCardImage)
        viewModelScope.launch {
            _transactionEvent.emit(CameraViewEvent.TRANSITION_TO_RESULT)
        }
    }
}