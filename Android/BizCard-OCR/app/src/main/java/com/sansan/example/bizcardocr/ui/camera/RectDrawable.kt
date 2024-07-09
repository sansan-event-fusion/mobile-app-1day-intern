package com.sansan.example.bizcardocr.ui.camera

import android.content.Context
import android.graphics.Canvas
import android.graphics.ColorFilter
import android.graphics.Paint
import android.graphics.PixelFormat
import android.graphics.Rect
import android.graphics.drawable.Drawable
import com.sansan.bizcardocr.app.R

// 矩形描画用に用意したクラスです。
// 必要であれば利用してください。
class RectDrawable(private val rect: Rect, context: Context) : Drawable() {
    private val boundingRectPaint = Paint().apply {
        style = Paint.Style.STROKE
        color = context.getColor(R.color.colorSecondary)
        strokeWidth = 4F
    }

    override fun draw(canvas: Canvas) {
        canvas.drawRect(rect, boundingRectPaint)
    }

    override fun setAlpha(alpha: Int) {
        boundingRectPaint.alpha = alpha
    }

    override fun setColorFilter(colorFiter: ColorFilter?) {
        boundingRectPaint.colorFilter = colorFilter
    }

    @Deprecated("Deprecated in Java")
    override fun getOpacity(): Int = PixelFormat.TRANSLUCENT
}