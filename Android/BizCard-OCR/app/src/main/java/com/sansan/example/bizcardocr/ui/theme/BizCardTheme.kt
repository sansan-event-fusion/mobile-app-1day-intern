package com.sansan.example.bizcardocr.ui.theme

import androidx.compose.material.MaterialTheme
import androidx.compose.material.lightColors
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color


private val lightColorScheme = lightColors(
    primary = Color(0xFF004E98),
    primaryVariant = Color(0xFF004E98), // 使う予定がないのでprimaryと同色
    secondary = Color(0xFF0579E6),
    secondaryVariant = Color(0xFF0579E6),// 使う予定がないのでsecondaryと同色
    background = Color(0xFFFFFFFF),
    surface = Color(0xFFFFFFFF),
    error = Color(0xFFCF6679),
)


@Composable
fun BizCardTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colors = lightColorScheme,
        typography = BizCardTypography.materialTypography,
        content = content
    )
}