package com.sansan.example.bizcardocr.ui.edit

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import com.sansan.example.bizcardocr.R
import com.sansan.example.bizcardocr.databinding.ActivityEditBinding
import kotlinx.coroutines.launch

class EditActivity : AppCompatActivity() {

    private val binding by lazy { ActivityEditBinding.inflate(layoutInflater) }

    private val viewModel: EditViewModel by viewModels {
        val bizCardId = this.intent.getLongExtra(EXTRA_KEY_BIZ_CARD_ID, -1)
        if (bizCardId == -1L) throw IllegalArgumentException()
        EditViewModel.EditViewModelFactory(bizCardId)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(binding.root)
        initToolbar()
        binding.included.registerButton.setOnClickListener {
            viewModel.onRegisterButtonPressed(
                name = binding.included.nameValueEditText.text.toString(),
                email = binding.included.mailValueEditText.text.toString(),
                tel = binding.included.telValueEditText.text.toString(),
                company = binding.included.companyNameValueEditText.text.toString()
            )
        }
        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                launch {
                    viewModel.viewState.collect {
                        binding.included.bizCardImage.setImageBitmap(it.cardImage)
                        binding.included.ocrStateDescription.text =
                            getString(R.string.card_crated_prefix, it.createdDateText)
                        binding.included.nameValueEditText.setText(it.name)
                        binding.included.companyNameValueEditText.setText(it.company)
                        binding.included.mailValueEditText.setText(it.email)
                        binding.included.telValueEditText.setText(it.tel)
                    }
                }
                launch {
                    viewModel.viewEvent.collect {
                        if (it == EditViewEvent.TRANSITION_TO_HOME) {
                            finish()
                        }
                    }
                }
            }
        }
    }

    private fun initToolbar() {
        setSupportActionBar(binding.toolbar)
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.setHomeButtonEnabled(true)
        supportActionBar?.setDisplayShowTitleEnabled(false)
        binding.toolbar.setNavigationOnClickListener {
            finish()
        }
    }

    companion object {
        private const val EXTRA_KEY_BIZ_CARD_ID = "EXTRA_KEY_BIZ_CARD_ID"
        fun createIntent(context: Context, bizCardId: Long): Intent {
            val intent = Intent(context, EditActivity::class.java)
            intent.putExtra(EXTRA_KEY_BIZ_CARD_ID, bizCardId)
            return intent
        }
    }
}