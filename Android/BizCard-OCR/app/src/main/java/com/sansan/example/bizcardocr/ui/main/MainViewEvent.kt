package com.sansan.example.bizcardocr.ui.main

sealed interface MainViewEvent {
    data class TransitionToDetail(
        val bizCardId: Long
    ) : MainViewEvent

    object TransitionToCamera : MainViewEvent

    object TransitionToGallery : MainViewEvent
}