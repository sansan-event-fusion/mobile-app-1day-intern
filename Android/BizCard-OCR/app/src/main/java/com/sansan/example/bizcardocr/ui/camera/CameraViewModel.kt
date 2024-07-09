package com.sansan.example.bizcardocr.ui.camera

import android.net.Uri
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class CameraViewModel : ViewModel() {

    private val _transactionEvent: MutableSharedFlow<CameraViewEvent> = MutableSharedFlow()
    val transactionEvent: SharedFlow<CameraViewEvent> = _transactionEvent.asSharedFlow()

    private val detectionModeSwitchState: MutableStateFlow<Boolean> = MutableStateFlow(false)
    private val isShutterButtonEnabledState: MutableStateFlow<Boolean> = MutableStateFlow(true)

    val viewState = combine(
        detectionModeSwitchState,
        isShutterButtonEnabledState
    ) { isDetectionModeSwitchEnabled, isShutterButtonEnabled ->
        CameraViewState(isDetectionModeSwitchEnabled, isShutterButtonEnabled)
    }.stateIn(
        viewModelScope,
        SharingStarted.Eagerly,
        CameraViewState(detectionModeSwitchState = false, isShutterButtonEnabled = true)
    )

    fun takePictureSuccess(imagePath: Uri) {
        isShutterButtonEnabledState.value = true
        viewModelScope.launch {
            imagePath.path?.let {
                _transactionEvent.emit(CameraViewEvent.TransitionToResult(it))
            }
        }
    }

    fun takePictureFailed() {
        isShutterButtonEnabledState.value = true
    }

    fun switchDetectionMode(enable: Boolean) {
        detectionModeSwitchState.value = enable
    }

    fun takePicture() {
        isShutterButtonEnabledState.value = false
    }

    fun finish() {
        viewModelScope.launch {
            _transactionEvent.emit(CameraViewEvent.TransitionToMain)
        }
    }
}