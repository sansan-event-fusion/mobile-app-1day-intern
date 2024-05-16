package com.sansan.example.bizcardocr.ui.edit

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import com.sansan.bizcardocr.app.R
import com.sansan.bizcardocr.app.databinding.ActivityEditBinding
import com.sansan.example.bizcardocr.BizCardOCRApplication
import kotlinx.coroutines.launch

class EditActivity : AppCompatActivity() {

    private val binding by lazy { ActivityEditBinding.inflate(layoutInflater) }

    private val viewModel: EditViewModel by viewModels {
        val bizCardOCRApplication = application as BizCardOCRApplication
        val bizCardId = this.intent.getLongExtra(EXTRA_KEY_BIZ_CARD_ID, -1)
        if (bizCardId == -1L) throw IllegalArgumentException()
        EditViewModel.EditViewModelFactory(bizCardId, bizCardOCRApplication.container)
    }

    // TODO: Jetpack Composeを使ったUI実装に変更してみましょう！
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(binding.root)
        initToolbar()

        binding.included.registerButton.setOnClickListener {
            // NOTE :
            // 現時点ではStateとEditTextが同期されていないので、EditTextの入力状態をViewModelに反映させる
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

                        // NOTE: Compose化を意識したState構成なのでEditTextで使うには向いていません
                        // 現時点ではEditTextでの変更がStateに反映されないので、StateとEditTextの不一致が起こります
                        binding.included.nameValueEditText.setText(it.cardForm.name)
                        binding.included.companyNameValueEditText.setText(it.cardForm.company)
                        binding.included.mailValueEditText.setText(it.cardForm.email)
                        binding.included.telValueEditText.setText(it.cardForm.tel)
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