package com.sansan.example.bizcardocr.ui.camera

import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Size
import android.view.Surface.ROTATION_0
import android.view.View
import android.view.WindowInsets
import android.view.WindowInsetsController
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageCapture
import androidx.camera.core.ImageCaptureException
import androidx.camera.core.ImageProxy
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import com.sansan.example.bizcardocr.databinding.ActivityCameraBinding
import com.sansan.example.bizcardocr.ui.result.ResultActivity
import kotlinx.coroutines.launch

class CameraActivity : AppCompatActivity() {

    private val binding by lazy { ActivityCameraBinding.inflate(layoutInflater) }
    private var imageCapture: ImageCapture? = null
    private val viewModel: CameraViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(binding.root)
        initCamera()
        initViews()

        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                viewModel
                    .transactionEvent
                    .collect {
                        when (it) {
                            CameraViewEvent.TRANSITION_TO_RESULT -> {
                                val intent = ResultActivity.createIntent(this@CameraActivity)
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
    }

    private fun initViews() {
        binding.shutterButton.setOnClickListener {
            takePicture()
        }
        binding.cancelButton.setOnClickListener {
            finish()
        }
    }

    private fun initCamera() {
        val cameraProviderFuture = ProcessCameraProvider.getInstance(this)
        cameraProviderFuture.addListener({
            val cameraProvider = cameraProviderFuture.get()
            val preview: Preview = Preview
                .Builder()
                .setTargetResolution(Size(1280, 720))
                .build()
            val imageCapture = ImageCapture
                .Builder()
                .setTargetResolution(Size(1280, 720))
                .setTargetRotation(ROTATION_0)
                .build()
                .also { this.imageCapture = it }

            binding.previewView.scaleType = PreviewView.ScaleType.FIT_CENTER
            preview.setSurfaceProvider(binding.previewView.surfaceProvider)

            cameraProvider.unbindAll()
            cameraProvider.bindToLifecycle(
                this,
                CameraSelector.DEFAULT_BACK_CAMERA,
                imageCapture,
                preview
            )
            binding.shutterButton.isEnabled = true
        }, ContextCompat.getMainExecutor(this))
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
        imageCapture?.takePicture(
            ContextCompat.getMainExecutor(this),
            object : ImageCapture.OnImageCapturedCallback() {
                override fun onError(error: ImageCaptureException) {
                    binding.shutterButton.isEnabled = true
                }

                override fun onCaptureSuccess(image: ImageProxy) {
                    viewModel.onTakePictureSuccess(convertImageProxyToByteArray(image))
                }
            })
    }

    private fun convertImageProxyToByteArray(imageProxy: ImageProxy): ByteArray {
        imageProxy.use {
            val buffer = imageProxy.planes[0].buffer
            buffer.rewind()
            val data = ByteArray(buffer.remaining())
            buffer.get(data)
            return data
        }
    }

    companion object {
        fun createIntent(context: Context): Intent =
            Intent(context, CameraActivity::class.java)
    }
}
