package com.sansan.example.bizcardocr.ui.result

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.activity.addCallback
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import com.sansan.bizcardocr.app.R
import com.sansan.bizcardocr.app.databinding.ActivityResultBinding
import com.sansan.example.bizcardocr.BizCardOCRApplication
import com.sansan.example.bizcardocr.ui.main.MainActivity
import kotlinx.coroutines.launch

class ResultActivity : AppCompatActivity() {

    private val viewModel: ResultViewModel by viewModels {
        val bizCardApplication = application as BizCardOCRApplication
        ResultViewModel.ResultViewModelFactory(
            bizCardApplication.container,
            intent.getStringExtra(EXTRA_KEY_TARGET_FILE_PATH)!!
        )
    }
    private val binding by lazy { ActivityResultBinding.inflate(layoutInflater) }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(binding.root)
        initToolBar()

        onBackPressedDispatcher.addCallback {
            viewModel.onBackButtonPressed()
        }

        binding.included.registerButton.setOnClickListener {
            // NOTE :
            // 現時点ではStateとEditTextが同期されていないので、EditTextの入力状態をViewModelに反映させる
            viewModel.onRegisterButtonPressed(
                binding.included.nameValueEditText.text.toString(),
                binding.included.companyNameValueEditText.text.toString(),
                binding.included.mailValueEditText.text.toString(),
                binding.included.telValueEditText.text.toString()
            )
        }

        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                launch {
                    viewModel
                        .viewEvent
                        .collect {
                            when (it) {
                                ResultViewEvent.TRANSITION_TO_CAPTURE -> finish()
                                ResultViewEvent.TRANSITION_TO_TOP -> {
                                    val intent = Intent(
                                        this@ResultActivity,
                                        MainActivity::class.java
                                    ).setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                                    startActivity(intent)
                                }
                            }
                        }
                }
                launch {
                    viewModel.viewState.collect {
                        binding.included.bizCardImage.setImageBitmap(it.capturedCardImage)
                        when (it.progress) {
                            OCRProgress.INIT -> {
                                binding.ocrResultArea.visibility = View.GONE
                                binding.groupOcrInprogress.visibility = View.INVISIBLE
                                binding.groupOcrError.visibility = View.INVISIBLE
                                binding.setTextEditable(false)
                            }

                            OCRProgress.IN_PROGRESS -> {
                                binding.ocrResultArea.visibility = View.VISIBLE
                                binding.groupOcrInprogress.visibility = View.VISIBLE
                                binding.groupOcrError.visibility = View.INVISIBLE
                                binding.setTextEditable(false)
                            }

                            OCRProgress.SUCCESS -> {
                                binding.ocrResultArea.visibility = View.GONE
                                binding.groupOcrInprogress.visibility = View.INVISIBLE
                                binding.groupOcrError.visibility = View.INVISIBLE
                                binding.setTextEditable(true)
                            }

                            OCRProgress.ERROR -> {
                                binding.ocrResultArea.visibility = View.VISIBLE
                                binding.groupOcrInprogress.visibility = View.INVISIBLE
                                binding.groupOcrError.visibility = View.VISIBLE
                                binding.setTextEditable(false)
                            }
                        }
                        when (it.isButtonEnabled) {
                            true -> binding.included.registerButton.isEnabled = true
                            false -> binding.included.registerButton.isEnabled = false
                        }
                        it.capturedCardImage?.let { bitmap ->
                            binding.included.bizCardImage.setImageBitmap(bitmap)
                        }
                        it.createdDateText.let { text ->
                            binding.included.ocrStateDescription.text =
                                getString(R.string.card_crated_prefix, text)
                        }
                        // NOTE: Compose化を意識したState構成なのでEditTextで使うには向いていません
                        // 現時点ではEditTextでの変更がStateに反映されないので、StateとEditTextの不一致が起こります
                        it.cardForm.let { cardForm ->
                            binding.included.nameValueEditText.setText(cardForm.name)
                            binding.included.companyNameValueEditText.setText(cardForm.company)
                            binding.included.mailValueEditText.setText(cardForm.email)
                            binding.included.telValueEditText.setText(cardForm.tel)
                        }
                    }
                }
            }
        }
    }

    private fun ActivityResultBinding.setTextEditable(flag: Boolean) {
        if (flag) {
            included.nameValueEditText.isFocusableInTouchMode = true
            included.mailValueEditText.isFocusableInTouchMode = true
            included.telValueEditText.isFocusableInTouchMode = true
            included.companyNameValueEditText.isFocusableInTouchMode = true
        } else {
            included.nameValueEditText.isFocusable = false
            included.mailValueEditText.isFocusable = false
            included.telValueEditText.isFocusable = false
            included.companyNameValueEditText.isFocusable = false
        }
    }

    private fun initToolBar() {
        setSupportActionBar(binding.toolbar)
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.setHomeButtonEnabled(true)
        supportActionBar?.setDisplayShowTitleEnabled(false)
        binding.toolbar.setNavigationOnClickListener {
            onBackPressedDispatcher.onBackPressed()
        }
    }

    companion object {
        const val EXTRA_KEY_TARGET_FILE_PATH = "EXTRA_KEY_TARGET_FILE_PATH"
        fun createIntent(context: Context, filePath: String): Intent =
            Intent(context, ResultActivity::class.java).apply {
                putExtra(EXTRA_KEY_TARGET_FILE_PATH, filePath)
            }
    }
}
