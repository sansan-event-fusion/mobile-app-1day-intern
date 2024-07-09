package com.sansan.example.bizcardocr.ui.camera

sealed interface CameraViewEvent {
    data class TransitionToResult(val cardImagePath: String) : CameraViewEvent

    data object TransitionToMain : CameraViewEvent
}