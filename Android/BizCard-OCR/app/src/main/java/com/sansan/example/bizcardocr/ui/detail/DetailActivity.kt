package com.sansan.example.bizcardocr.ui.detail

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import com.sansan.example.bizcardocr.R
import com.sansan.example.bizcardocr.databinding.ActivityDetailBinding
import com.sansan.example.bizcardocr.ui.edit.EditActivity
import kotlinx.coroutines.launch

class DetailActivity : AppCompatActivity() {

    private val binding by lazy { ActivityDetailBinding.inflate(layoutInflater) }

    private val viewModel: DetailViewModel by viewModels {
        val bizCardId = this.intent.getLongExtra(EXTRA_KEY_BIZ_CARD_ID, -1)
        if (bizCardId == -1L) throw IllegalArgumentException()
        DetailViewModel.DetailViewModelFactory(bizCardId)
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
                    binding.bizCardImage.setImageBitmap(it.cardImage)
                    binding.createdDate.text =
                        getString(R.string.card_crated_prefix, it.createdDateText)
                    binding.nameValueEditText.text = it.name
                    binding.companyNameValueEditText.text = it.company
                    binding.telValueEditText.text = it.tel
                    binding.mailValueEditText.text = it.email
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
            val intent = Intent(context, DetailActivity::class.java)
            intent.putExtra(EXTRA_KEY_BIZ_CARD_ID, bizCardId)
            return intent
        }
    }
}