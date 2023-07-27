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
import com.sansan.example.bizcardocr.R
import com.sansan.example.bizcardocr.databinding.ActivityResultBinding
import com.sansan.example.bizcardocr.ui.main.MainActivity
import kotlinx.coroutines.launch

class ResultActivity : AppCompatActivity() {

    private val viewModel: ResultViewModel by viewModels()

    private val binding by lazy { ActivityResultBinding.inflate(layoutInflater) }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(binding.root)
        initToolBar()

        onBackPressedDispatcher.addCallback {
            viewModel.onBackButtonPressed()
        }

        binding.included.registerButton.setOnClickListener {
            viewModel.onRegisterButtonPressed(
                name = binding.included.nameValueEditText.text.toString(),
                company = binding.included.companyNameValueEditText.text.toString(),
                email = binding.included.mailValueEditText.text.toString(),
                tel = binding.included.telValueEditText.text.toString()
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
                        when (it) {
                            is ResultViewState.InProgress -> {
                                binding.ocrResultArea.visibility = View.VISIBLE
                                binding.groupOcrInprogress.visibility = View.VISIBLE
                                binding.groupOcrError.visibility = View.INVISIBLE
                                binding.included.registerButton.isEnabled = false
                                binding.setTextEditable(false)
                            }

                            is ResultViewState.Success -> {
                                binding.ocrResultArea.visibility = View.GONE
                                binding.groupOcrInprogress.visibility = View.INVISIBLE
                                binding.groupOcrError.visibility = View.INVISIBLE
                                binding.included.ocrStateDescription.text =
                                    getString(R.string.card_crated_prefix, it.createdDateText)
                                binding.included.nameValueEditText.setText(it.name)
                                binding.included.mailValueEditText.setText(it.email)
                                binding.included.telValueEditText.setText(it.tel)
                                binding.setTextEditable(true)
                                binding.included.companyNameValueEditText.setText(it.company)
                                binding.included.registerButton.isEnabled = true
                            }

                            is ResultViewState.Error -> {
                                binding.ocrResultArea.visibility = View.VISIBLE
                                binding.groupOcrInprogress.visibility = View.INVISIBLE
                                binding.groupOcrError.visibility = View.VISIBLE
                                binding.included.registerButton.isEnabled = false
                                binding.setTextEditable(false)
                            }
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
        fun createIntent(context: Context): Intent =
            Intent(context, ResultActivity::class.java)
    }
}
