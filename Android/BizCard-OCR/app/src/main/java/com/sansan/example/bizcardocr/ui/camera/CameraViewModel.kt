package com.sansan.example.bizcardocr.ui.camera

import android.net.Uri
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.launch

class CameraViewModel : ViewModel() {

    private val _transactionEvent: MutableSharedFlow<CameraViewEvent> = MutableSharedFlow()
    val transactionEvent: SharedFlow<CameraViewEvent> = _transactionEvent.asSharedFlow()

    fun takePictureSuccess(imagePath: Uri) {
        viewModelScope.launch {
            imagePath.path?.let {
                _transactionEvent.emit(CameraViewEvent.TransitionToResult(it))
            }
        }
    }
}