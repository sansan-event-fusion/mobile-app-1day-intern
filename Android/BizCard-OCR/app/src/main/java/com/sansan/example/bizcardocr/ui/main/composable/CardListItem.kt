package com.sansan.example.bizcardocr.ui.main.composable

import android.graphics.Bitmap
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material.Surface
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.sansan.example.bizcardocr.ui.theme.BizCardColor
import com.sansan.example.bizcardocr.ui.theme.BizCardTheme
import com.sansan.example.bizcardocr.ui.theme.BizCardTypography

@Composable
fun CardListSection(
    modifier: Modifier = Modifier,
    sectionYear: String,
    sectionMonth: String,
    sectionDay: String
) {
    Surface(
        modifier = modifier,
        color = BizCardColor.Background.Section
    ) {
        Column(
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
        ) {
            Text(
                text = "$sectionYear/$sectionMonth/$sectionDay",
                style = BizCardTypography.Subtitle2
            )
        }
    }
}

@Composable
fun CardListItem(
    modifier: Modifier = Modifier,
    contentPadding: PaddingValues = PaddingValues(16.dp),
    name: String,
    company: String,
    departmentAndTitle: String,
    cardImage: Bitmap,
) {
    Surface(
        modifier = modifier.padding(contentPadding)
    ) {
        Row {
            Column(
                Modifier.weight(1f)
            ) {
                Text(
                    text = name,
                    style = BizCardTypography.Subtitle1
                )
                Text(
                    text = company,
                    style = BizCardTypography.Caption
                )
                Text(
                    text = departmentAndTitle,
                    style = BizCardTypography.Caption
                )
            }
            Spacer(modifier = Modifier.width(16.dp))
            Box(
                contentAlignment = Alignment.Center
            ) {
                Image(
                    modifier = Modifier
                        .size(80.dp, 60.dp),
                    bitmap = cardImage.asImageBitmap(),
                    contentDescription = null
                )
            }
        }
    }
}

@Composable
@Preview
fun CardListItemPreview() {
    BizCardTheme {
        CardListItem(
            modifier = Modifier.fillMaxWidth(),
            name = "田中 徳兵衛",
            company = "浅葉建設株式会社",
            departmentAndTitle = "営業本部",
            cardImage = Bitmap.createBitmap(400, 300, Bitmap.Config.ARGB_8888)
        )
    }
}

@Composable
@Preview
fun CardListSectionPreview() {
    BizCardTheme {
        CardListSection(
            modifier = Modifier.fillMaxWidth(),
            sectionYear = "2021",
            sectionMonth = "01",
            sectionDay = "01"
        )
    }
}


