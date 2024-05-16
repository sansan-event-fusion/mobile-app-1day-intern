package com.sansan.example.bizcardocr.ui.main.composable

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.Divider
import androidx.compose.material.ExtendedFloatingActionButton
import androidx.compose.material.Icon
import androidx.compose.material.Scaffold
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.sansan.bizcardocr.app.R
import com.sansan.example.bizcardocr.ui.main.CardListItem
import com.sansan.example.bizcardocr.ui.main.MainAppBarMenu
import com.sansan.example.bizcardocr.ui.main.MainViewModel
import com.sansan.example.bizcardocr.ui.main.MainViewState
import com.sansan.example.bizcardocr.ui.theme.BizCardColor
import com.sansan.example.bizcardocr.ui.theme.BizCardTypography

@Composable
fun MainScreenHolder(
    mainViewModel: MainViewModel
) {
    val state = mainViewModel.viewState.collectAsState().value
    MainScreen(
        viewState = state,
        onListItemClicked = { card -> mainViewModel.onListItemClicked(card) },
        onSearchMenuClick = { mainViewModel.showSearchAppBar() },
        onMenuClick = { mainViewModel.showMenu() },
        onDismissOptionMenu = { mainViewModel.dismissOptionMenu() },
        onMenuItemClick = { item -> mainViewModel.applyOption(item) },
        onBackButtonPressed = { mainViewModel.showDefaultAppBar() },
        onQueryChange = { query -> mainViewModel.queryChange(query) },
        onCameraButtonCLicked = { mainViewModel.launchCamera() }
    )
}

@Composable
fun MainScreen(
    viewState: MainViewState,
    onListItemClicked: (CardListItem.BizCard) -> Unit,
    onSearchMenuClick: () -> Unit,
    onMenuClick: () -> Unit,
    onDismissOptionMenu: () -> Unit,
    onMenuItemClick: (MainAppBarMenu) -> Unit,
    onBackButtonPressed: () -> Unit,
    onQueryChange: (String) -> Unit,
    onCameraButtonCLicked: () -> Unit
) {
    Scaffold(
        topBar = {
            MainAppBar(
                appBarState = viewState.appBarState,
                onSearchMenuClick = onSearchMenuClick,
                onMenuClick = onMenuClick,
                onDismissOptionMenu = onDismissOptionMenu,
                onMenuItemClick = onMenuItemClick,
                onBackButtonPressed = onBackButtonPressed,
                onQueryChange = onQueryChange
            )
        },
        floatingActionButton = {
            ExtendedFloatingActionButton(
                modifier = Modifier.height(44.dp),
                contentColor = BizCardColor.TextColorWhite,
                text = {
                    Text(
                        text = stringResource(id = R.string.main_activity_camera_button_label),
                        style = BizCardTypography.Button
                    )
                },
                icon = {
                    Icon(
                        painter = painterResource(id = R.drawable.icon_camera),
                        contentDescription = null,
                        tint = BizCardColor.TextColorWhite
                    )
                },
                onClick = onCameraButtonCLicked
            )
        }
    ) { paddingValue ->
        LazyColumn(
            modifier = Modifier.padding(paddingValue),
        ) {
            items(viewState.cardList) { cardListItem ->
                when (cardListItem) {
                    is CardListItem.BizCard -> {
                        CardListItem(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable {
                                    onListItemClicked(cardListItem)
                                },
                            name = cardListItem.name,
                            company = cardListItem.company,
                            departmentAndTitle = cardListItem.departmentAndTitle,
                            cardImage = cardListItem.cardImage
                        )
                        Divider(Modifier.height(1.dp), color = BizCardColor.BorderLine)
                    }

                    is CardListItem.Section -> {
                        CardListSection(
                            modifier = Modifier.fillMaxWidth(),
                            sectionYear = cardListItem.sectionYear,
                            sectionMonth = cardListItem.sectionMonth,
                            sectionDay = cardListItem.sectionDay
                        )
                    }
                }
            }
        }
    }
}

