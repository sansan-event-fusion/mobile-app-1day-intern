package com.sansan.example.bizcardocr.ui.main

import android.Manifest
import android.os.Bundle
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.sansan.example.bizcardocr.R
import com.sansan.example.bizcardocr.databinding.ActivityMainBinding
import com.sansan.example.bizcardocr.ui.camera.CameraActivity
import com.sansan.example.bizcardocr.ui.detail.DetailActivity
import kotlinx.coroutines.launch

class MainActivity : AppCompatActivity() {

    private val viewModel by viewModels<MainViewModel>()
    private val adapter by lazy { CardListAdapter(viewModel) }

    private val requestCameraPermissionLauncher =
        registerForActivityResult(ActivityResultContracts.RequestPermission()) { isGranted ->
            if (isGranted) {
                showCamera()
            } else {
                showCameraPermissionDeniedMessage()
            }
        }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.addCardFab.setOnClickListener {
            requestCameraPermissionLauncher.launch(Manifest.permission.CAMERA)
        }

        binding.sortSettingArea.setOnClickListener {
            AlertDialog
                .Builder(this)
                .setItems(
                    arrayOf(
                        getString(R.string.main_activity_item_ascending_order),
                        getString(R.string.main_activity_item_descending_order)
                    )
                ) { _, which ->
                    when (which) {
                        0 -> TODO("昇順に並び替える")
                        1 -> TODO("降順に並び替える")
                    }
                }.show()
        }

        binding.cardList.adapter = adapter
        binding.cardList.layoutManager = LinearLayoutManager(this, RecyclerView.VERTICAL, false)

        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                launch {
                    viewModel.viewState.collect {
                        adapter.submitList(it.cardList)
                    }
                }
                launch {
                    viewModel.viewEvent.collect {
                        when (it) {
                            is MainViewEvent.TransitionToDetail -> {
                                val intent =
                                    DetailActivity.createIntent(this@MainActivity, it.bizCardId)
                                startActivity(intent)
                            }
                        }
                    }
                }
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
