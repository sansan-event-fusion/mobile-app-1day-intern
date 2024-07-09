package com.sansan.example.bizcardocr.ui.camera

import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.View
import android.view.WindowInsets
import android.view.WindowInsetsController
import androidx.activity.viewModels
import androidx.annotation.OptIn
import androidx.appcompat.app.AppCompatActivity
import androidx.camera.core.CameraSelector
import androidx.camera.core.ExperimentalGetImage
import androidx.camera.core.ImageCapture
import androidx.camera.core.ImageCaptureException
import androidx.camera.core.ImageProxy
import androidx.camera.view.LifecycleCameraController
import androidx.core.content.ContextCompat
import androidx.core.net.toUri
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import com.google.mlkit.vision.common.InputImage
import com.sansan.bizcardocr.app.databinding.ActivityCameraBinding
import com.sansan.example.bizcardocr.ui.result.ResultActivity
import kotlinx.coroutines.launch
import java.io.File
import java.io.FileOutputStream
import java.text.SimpleDateFormat
import java.util.Locale

class CameraActivity : AppCompatActivity() {

    private val binding by lazy { ActivityCameraBinding.inflate(layoutInflater) }
    private val viewModel: CameraViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(binding.root)

        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                viewModel
                    .transactionEvent
                    .collect {
                        when (it) {
                            is CameraViewEvent.TransitionToResult -> {
                                val intent = ResultActivity.createIntent(
                                    this@CameraActivity,
                                    it.cardImagePath
                                )
                                startActivity(intent)
                            }

                            is CameraViewEvent.TransitionToMain -> {
                                finish()
                            }
                        }
                    }
            }
        }
        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                viewModel
                    .viewState
                    .collect {
                        // 前の矩形描画を消す
                        binding.previewView.overlay.clear()
                        // ViewModelからの状態変更を受け取り、UIを更新する
                        binding.shutterButton.isEnabled = it.isShutterButtonEnabled
                        // TODO: 矩形が検出されたら、RectDrawableクラスを使って矩形を描画しましょう
                    }
            }
        }

        binding.detectionSwitch.setOnCheckedChangeListener { _, isChecked ->
            viewModel.switchDetectionMode(isChecked)
        }

        binding.fromGallery.setOnClickListener {
            // TODO: アルバムから写真を選択できるようにしましょう！
        }

        binding.cancelButton.setOnClickListener {
            viewModel.finish()
        }

        cameraSetting()
    }

    /**
     * カメラの設定を行う
     */
    private fun cameraSetting() {
        // カメラのコントローラーを生成
        val cameraController = LifecycleCameraController(this)
        // カメラのオープン、ストップ、クローズ、破棄をActivityのライフサイクルに紐付ける
        cameraController.bindToLifecycle(this)
        // 背面のカメラを使うように指定
        cameraController.cameraSelector = CameraSelector.DEFAULT_BACK_CAMERA
        // previewViewにカメラのコントローラーをセット
        binding.previewView.controller = cameraController

        // TODO: 物体検出を行うためのMlKitAnalyzerの設定をしましょう！

        // シャッターボタンを押したときの処理
        binding.shutterButton.setOnClickListener {
            viewModel.takePicture()
            cameraController.takePicture(
                ContextCompat.getMainExecutor(this),
                object : ImageCapture.OnImageCapturedCallback() {
                    @OptIn(ExperimentalGetImage::class)
                    override fun onCaptureSuccess(imageProxy: ImageProxy) {
                        val outPutFileName = SimpleDateFormat(
                            "yyyyMMddHHmmssSSS",
                            Locale.JAPAN
                        ).format(System.currentTimeMillis())
                        val outputDir = getDir("card_images", Context.MODE_PRIVATE).apply {
                            setWritable(true)
                        }
                        val imageFile = File(outputDir, "$outPutFileName.jpg")
                        val image = InputImage.fromMediaImage(
                            imageProxy.image!!,
                            imageProxy.imageInfo.rotationDegrees
                        )
                        if (viewModel.viewState.value.detectionModeSwitchState) {
                            // TODO: 物体検出で検出された領域で名刺画像の切り取りを行いましょう
                        } else {
                            // 物体検出を行わない場合はそのまま画像を保存する
                            FileOutputStream(imageFile).use { fileOutputStream ->
                                imageProxy.toBitmap().compress(
                                    Bitmap.CompressFormat.JPEG,
                                    100,
                                    fileOutputStream
                                )
                            }
                            viewModel.takePictureSuccess(imageFile.toUri())
                            imageProxy.close()
                        }
                    }

                    override fun onError(exception: ImageCaptureException) {
                        Log.e("CameraActivity", exception.toString())
                        viewModel.takePictureFailed()
                    }
                }
            )
        }
    }

    override fun onResume() {
        super.onResume()
        setFullScreen()
    }

    private fun setFullScreen() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.insetsController?.hide(WindowInsets.Type.statusBars() or WindowInsets.Type.navigationBars())
            window.insetsController?.systemBarsBehavior =
                WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
        } else {
            window.decorView.systemUiVisibility =
                View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or
                        View.SYSTEM_UI_FLAG_FULLSCREEN or
                        View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or
                        View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or
                        View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
        }
    }

    companion object {
        fun createIntent(context: Context): Intent =
            Intent(context, CameraActivity::class.java)
    }
}