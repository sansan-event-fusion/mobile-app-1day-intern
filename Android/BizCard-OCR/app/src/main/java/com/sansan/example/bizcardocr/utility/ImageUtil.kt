package com.sansan.example.bizcardocr.utility

import android.graphics.Bitmap
import android.graphics.BitmapFactory

fun ByteArray.createBitmapFromJpeg(): Bitmap = BitmapFactory.decodeByteArray(
    this,
    0,
    this.size
)