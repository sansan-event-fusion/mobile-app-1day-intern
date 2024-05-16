package com.sansan.example.bizcardocr.ui.detail

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.EditText
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import com.sansan.bizcardocr.app.R
import com.sansan.bizcardocr.app.databinding.ActivityDetailBinding
import com.sansan.example.bizcardocr.BizCardOCRApplication
import com.sansan.example.bizcardocr.ui.edit.EditActivity
import kotlinx.coroutines.launch

class DetailActivity : AppCompatActivity() {

    private val binding by lazy { ActivityDetailBinding.inflate(layoutInflater) }

    private val viewModel: DetailViewModel by viewModels {
        val bizCardOCRApplication = application as BizCardOCRApplication
        val bizCardId = this.intent.getLongExtra(EXTRA_KEY_BIZ_CARD_ID, -1)
        if (bizCardId == -1L) throw IllegalArgumentException()
        DetailViewModel.DetailViewModelFactory(bizCardId, bizCardOCRApplication.container)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(binding.root)
        initToolbar()

        binding.iconEdit.setOnClickListener {
            val bizCardId = this.intent.getLongExtra(EXTRA_KEY_BIZ_CARD_ID, -1)
            if (bizCardId == -1L) throw IllegalArgumentException()
            val intent = EditActivity.createIntent(this, bizCardId)
            startActivity(intent)
        }

        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                viewModel.viewState.collect {
                    binding.included.bizCardImage.setImageBitmap(it.cardImage)
                    binding.included.ocrStateDescription.text =
                        getString(R.string.card_crated_prefix, it.createdDateText)
                    binding.included.nameValueEditText.setViewOnly(it.name)
                    binding.included.companyNameValueEditText.setViewOnly(it.company)
                    binding.included.telValueEditText.setViewOnly(it.tel)
                    binding.included.mailValueEditText.setViewOnly(it.email)
                    binding.included.registerButton.visibility = View.INVISIBLE
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

    private fun EditText.setViewOnly(text: String) {
        setText(text)
        isFocusable = false
        isEnabled = false
    }

    companion object {
        private const val EXTRA_KEY_BIZ_CARD_ID = "EXTRA_KEY_BIZ_CARD_ID"
        fun createIntent(context: Context, bizCardId: Long): Intent {
            val intent = Intent(context, DetailActivity::class.java)
            intent.putExtra(EXTRA_KEY_BIZ_CARD_ID, bizCardId)
            return intent
        }
    }
}