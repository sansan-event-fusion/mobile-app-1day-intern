package com.sansan.example.bizcardocr.ui.theme

import androidx.compose.material.Typography
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.sp

data object BizCardTypography {
    val H1: TextStyle = Typography().h1.copy(
        fontSize = 24.sp
    )
    val H2: TextStyle = Typography().h2.copy(
        fontSize = 20.sp
    )
    val H3: TextStyle = Typography().h3.copy(
        fontSize = 18.sp
    )
    val H4: TextStyle = Typography().h4.copy(
        fontSize = 16.sp
    )
    val H5: TextStyle = Typography().h5.copy(
        fontSize = 14.sp
    )
    val H6: TextStyle = Typography().h6.copy(
        fontSize = 12.sp
    )
    val Subtitle1: TextStyle = Typography().subtitle1.copy(
        fontSize = 16.sp,
        color = BizCardColor.Text.Primary
    )
    val Subtitle2: TextStyle = Typography().subtitle2.copy(
        fontSize = 14.sp,
        color = BizCardColor.Text.Secondary
    )
    val Body1: TextStyle = Typography().body1.copy(
        fontSize = 16.sp
    )
    val Body2: TextStyle = Typography().body1.copy(
        fontSize = 16.sp
    )
    val Button: TextStyle = Typography().button.copy(
        fontSize = 14.sp
    )
    val Caption: TextStyle = Typography().caption.copy(
        fontSize = 12.sp,
        color = BizCardColor.Text.Secondary
    )
    val materialTypography: Typography = Typography(
        h1 = H1,
        h2 = H2,
        h3 = H3,
        h4 = H4,
        h5 = H5,
        h6 = H6,
        subtitle1 = Subtitle1,
        subtitle2 = Subtitle2,
        button = Button,
        body1 = Body1,
        body2 = Body2,
        caption = Caption
    )

    val Body1White: TextStyle = Typography().body1.copy(
        fontSize = 16.sp,
        color = BizCardColor.TextColorWhite
    )
}