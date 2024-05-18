package com.sansan.example.bizcardocr.ui.camera

import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.Surface.ROTATION_0
import android.view.View
import android.view.WindowInsets
import android.view.WindowInsetsController
import androidx.activity.viewModels
import androidx.annotation.OptIn
import androidx.appcompat.app.AppCompatActivity
import androidx.camera.core.CameraSelector
import androidx.camera.core.ExperimentalGetImage
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageCapture
import androidx.camera.core.ImageCaptureException
import androidx.camera.core.ImageProxy
import androidx.camera.core.Preview
import androidx.camera.core.UseCaseGroup
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.content.ContextCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import com.sansan.bizcardocr.app.databinding.ActivityCameraBinding
import com.sansan.example.bizcardocr.ui.result.ResultActivity
import kotlinx.coroutines.launch
import java.io.File
import java.text.SimpleDateFormat
import java.util.Locale
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class CameraActivity : AppCompatActivity() {

    private val binding by lazy { ActivityCameraBinding.inflate(layoutInflater) }
    private var imageCapture: ImageCapture? = null
    private val viewModel: CameraViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(binding.root)

        // TODO: 矩形認識の領域描画の処理を書きましょう

        initCamera()
        initViews()


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
                        }
                    }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        setFullScreen()
        binding.shutterButton.isEnabled = true
    }

    private fun initViews() {
        binding.shutterButton.setOnClickListener {
            takePicture()
        }
        binding.cancelButton.setOnClickListener {
            finish()
        }
        binding.pickFromGallery.setOnClickListener {
            // TODO: アルバムから名刺画像を取得する処理を作りましょう
        }
        binding.detectionSwitch.setOnClickListener {

        }
    }

    private fun initCamera() {
        val cameraExecutor: ExecutorService = Executors.newSingleThreadExecutor()
        val cameraProviderFuture = ProcessCameraProvider.getInstance(this)
        cameraProviderFuture.addListener({
            val cameraProvider = cameraProviderFuture.get()
            val preview: Preview = Preview.Builder().build()
            val imageCapture = ImageCapture.Builder()
                .setTargetRotation(ROTATION_0)
                .build()
                .also { this.imageCapture = it }

            val imageAnalysis = ImageAnalysis.Builder().build().apply {
                setAnalyzer(cameraExecutor, CardAnalyzer())
            }

            preview.setSurfaceProvider(binding.previewView.surfaceProvider)

            cameraProvider.unbindAll()
            val useCaseGroup = binding.previewView.viewPort?.let { viewPort ->
                UseCaseGroup
                    .Builder()
                    .addUseCase(preview)
                    .addUseCase(imageCapture)
                    .addUseCase(imageAnalysis)
                    .setViewPort(viewPort)
                    .build()
            } ?: throw IllegalStateException("ViewPort could not be found.")

            cameraProvider.bindToLifecycle(
                this,
                CameraSelector.DEFAULT_BACK_CAMERA,
                useCaseGroup
            )
            binding.shutterButton.isEnabled = true
        }, ContextCompat.getMainExecutor(this))
    }

    /**
     *  TODO:
     *  矩形認識に必要なクラスです
     *  必要な引数を追加してください
     *  */
    class CardAnalyzer :
        ImageAnalysis.Analyzer {
        @OptIn(ExperimentalGetImage::class)
        override fun analyze(imageProxy: ImageProxy) {
            val mediaImage = imageProxy.image
            if (mediaImage != null) {
                // TODO : 矩形認識処理
            }
        }
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

    private fun takePicture() {
        binding.shutterButton.isEnabled = false
        val outPutFileName = SimpleDateFormat(
            "yyyyMMddHHmmssSSS",
            Locale.JAPAN
        ).format(System.currentTimeMillis())
        val outputDir = getDir("card_images", Context.MODE_PRIVATE).apply {
            setWritable(true)
        }
        val outPutOption = ImageCapture.OutputFileOptions.Builder(
            File(outputDir, "$outPutFileName.jpg")
        ).build()

        // TODO: 矩形認識の発展になりますが、矩形切り取りにも挑戦してみましょう
        imageCapture?.takePicture(
            outPutOption,
            ContextCompat.getMainExecutor(this),
            object : ImageCapture.OnImageSavedCallback {
                override fun onError(exc: ImageCaptureException) {
                    Log.e("CameraActivity", exc.toString())
                    binding.shutterButton.isEnabled = true
                }

                override fun onImageSaved(output: ImageCapture.OutputFileResults) {
                    output.savedUri?.let {
                        viewModel.takePictureSuccess(it)
                    } ?: run {
                        Log.e("CameraActivity", "ImageCapture.OutputFileResults.savedUri is null")
                        binding.shutterButton.isEnabled = true
                    }
                }
            }
        )
    }

    companion object {
        fun createIntent(context: Context): Intent =
            Intent(context, CameraActivity::class.java)
    }
}