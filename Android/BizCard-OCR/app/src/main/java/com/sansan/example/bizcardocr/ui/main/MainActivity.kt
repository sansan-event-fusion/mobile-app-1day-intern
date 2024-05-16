package com.sansan.example.bizcardocr.ui.main

import android.Manifest
import android.os.Bundle
import android.widget.Toast
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import com.sansan.bizcardocr.app.R
import com.sansan.example.bizcardocr.BizCardOCRApplication
import com.sansan.example.bizcardocr.ui.camera.CameraActivity
import com.sansan.example.bizcardocr.ui.detail.DetailActivity
import com.sansan.example.bizcardocr.ui.main.composable.MainScreenHolder
import com.sansan.example.bizcardocr.ui.theme.BizCardTheme
import kotlinx.coroutines.launch

class MainActivity : AppCompatActivity() {

    private val viewModel: MainViewModel by viewModels {
        val bizCardOCRApplication = application as BizCardOCRApplication
        MainViewModel.MainViewModelFactory(bizCardOCRApplication.container)
    }

    private val requestCameraPermissionLauncher =
        registerForActivityResult(ActivityResultContracts.RequestPermission()) { isGranted ->
            if (isGranted) {
                showCamera()
            } else {
                showCameraPermissionDeniedMessage()
            }
        }


    // TODO : アルバムから名刺画像を取得する処理を作りましょう
    // private val getLocalImageLauncher: ActivityResultLauncher<String> =

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                viewModel.viewEvent.collect {
                    when (it) {
                        is MainViewEvent.TransitionToDetail -> {
                            val intent =
                                DetailActivity.createIntent(this@MainActivity, it.bizCardId)
                            startActivity(intent)
                        }

                        is MainViewEvent.TransitionToCamera -> {
                            requestCameraPermissionLauncher.launch(Manifest.permission.CAMERA)
                        }

                        is MainViewEvent.TransitionToGallery -> {
                            // TODO: アルバムから名刺画像を取得する処理を作りましょう
                        }
                    }
                }
            }
        }

        setContent {
            BizCardTheme {
                MainScreenHolder(mainViewModel = viewModel)
            }
        }
    }

    private fun showCamera() {
        startActivity(CameraActivity.createIntent(this))
    }

    private fun showCameraPermissionDeniedMessage() {
        Toast.makeText(this, R.string.permission_camera_never_ask_again, Toast.LENGTH_SHORT).show()
    }
}
