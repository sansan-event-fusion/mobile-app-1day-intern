package com.sansan.example.bizcardocr.ui.main.composable

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material.DropdownMenu
import androidx.compose.material.DropdownMenuItem
import androidx.compose.material.Icon
import androidx.compose.material.IconButton
import androidx.compose.material.Text
import androidx.compose.material.TopAppBar
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.sansan.bizcardocr.app.R
import com.sansan.example.bizcardocr.ui.main.AppBarState
import com.sansan.example.bizcardocr.ui.main.MainAppBarMenu
import com.sansan.example.bizcardocr.ui.theme.BizCardColor
import com.sansan.example.bizcardocr.ui.theme.BizCardTheme
import com.sansan.example.bizcardocr.ui.theme.BizCardTypography

@Composable
fun MainAppBar(
    appBarState: AppBarState,
    onSearchMenuClick: () -> Unit,
    onMenuClick: () -> Unit,
    onDismissOptionMenu: () -> Unit,
    onMenuItemClick: (MainAppBarMenu) -> Unit,
    onBackButtonPressed: () -> Unit,
    onQueryChange: (String) -> Unit
) {
    when (appBarState) {
        is AppBarState.Default -> {
            DefaultAppBar(
                menuExpanded = appBarState.showOptionMenu,
                onSearchMenuClick = { onSearchMenuClick() },
                onMenuClick = { onMenuClick() },
                onDismissOptionMenu = { onDismissOptionMenu() },
                onMenuItemClick = { item -> onMenuItemClick(item) }
            )
        }

        is AppBarState.Search -> {
            SearchAppBar(
                query = appBarState.query,
                onBackButtonPressed = onBackButtonPressed,
                onQueryChange = onQueryChange
            )
        }
    }
}

@Composable
fun SearchAppBar(
    modifier: Modifier = Modifier,
    query: String,
    onBackButtonPressed: () -> Unit,
    onQueryChange: (String) -> Unit
) {
    TopAppBar {
        Row(
            modifier = modifier,
            verticalAlignment = Alignment.CenterVertically
        ) {
            IconButton(onClick = { onBackButtonPressed() }) {
                Icon(
                    imageVector = Icons.Default.ArrowBack,
                    contentDescription = null,
                    tint = BizCardColor.Icon.White
                )
            }
            BasicTextField(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(top = 8.dp, bottom = 8.dp, end = 16.dp),
                value = query,
                onValueChange = { onQueryChange(it) },
                textStyle = BizCardTypography.Body1White,
                cursorBrush = SolidColor(BizCardColor.TextColorWhite),
                decorationBox = { innerTextField ->
                    Box(
                        Modifier.fillMaxSize(),
                        contentAlignment = Alignment.CenterStart
                    ) {
                        innerTextField()
                        if (query.isEmpty()) {
                            Text(
                                text = stringResource(id = R.string.appbar_search_hint),
                                style = BizCardTypography.Body1
                            )
                        }
                    }
                }
            )
        }
    }
}

@Composable
fun DefaultAppBar(
    modifier: Modifier = Modifier,
    menuExpanded: Boolean = false,
    onSearchMenuClick: () -> Unit,
    onMenuClick: () -> Unit,
    onDismissOptionMenu: () -> Unit,
    onMenuItemClick: (MainAppBarMenu) -> Unit
) {
    TopAppBar(
        modifier = modifier,
        title = @Composable {
            Image(
                alignment = Alignment.CenterStart,
                modifier = Modifier.padding(start = 57.dp),
                painter = painterResource(id = R.mipmap.image_company_logo),
                contentDescription = null
            )
        },
        actions = @Composable {
            IconButton(onClick = { onSearchMenuClick() }) {
                Icon(
                    painter = painterResource(id = R.drawable.icon_search),
                    contentDescription = null,
                    tint = BizCardColor.Icon.White
                )
            }
            IconButton(onClick = { onMenuClick() }) {
                Icon(
                    imageVector = Icons.Default.MoreVert,
                    contentDescription = null,
                    tint = BizCardColor.Icon.White
                )
                DropdownMenu(
                    expanded = menuExpanded,
                    onDismissRequest = { onDismissOptionMenu() }) {
                    DropdownMenuItem(onClick = { onMenuItemClick(MainAppBarMenu.SORT_BY_DATE_ASC) }) {
                        Text(stringResource(id = R.string.appbar_option_asc))
                    }
                    DropdownMenuItem(onClick = { onMenuItemClick(MainAppBarMenu.SORT_BY_DATE_DESC) }) {
                        Text(stringResource(id = R.string.appbar_option_desc))
                    }
                }
            }
        }
    )
}

@Composable
@Preview()
fun DefaultAppBarPreview() {
    BizCardTheme {
        DefaultAppBar(
            menuExpanded = true,
            onSearchMenuClick = { },
            onMenuClick = { },
            onDismissOptionMenu = { },
            onMenuItemClick = { }
        )
    }
}

@Composable
@Preview()
fun SearchAppBarPreview() {
    BizCardTheme {
        SearchAppBar(
            query = "aaa",
            onBackButtonPressed = { },
            onQueryChange = { }
        )
    }
}