package com.sansan.example.bizcardocr.ui.main

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import androidx.viewbinding.ViewBinding
import com.sansan.example.bizcardocr.databinding.ListItemBizCardBinding
import com.sansan.example.bizcardocr.databinding.ListItemBizCardDateBinding

class CardListAdapter(private val viewModel: MainViewModel) :
    ListAdapter<CardListItem, CardListItemViewHolder>(diffCallback) {
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): CardListItemViewHolder {
        return when (CardListItemViewType.of(viewType)) {
            CardListItemViewType.CARD -> {
                val binding = ListItemBizCardBinding.inflate(
                    LayoutInflater.from(parent.context),
                    parent,
                    false
                )
                CardListItemBizCardViewHolder(binding, viewModel)
            }

            CardListItemViewType.SECTION -> {
                val binding = ListItemBizCardDateBinding.inflate(
                    LayoutInflater.from(parent.context),
                    parent,
                    false
                )
                CardListItemSectionViewHolder(binding)
            }
        }
    }

    override fun onBindViewHolder(holder: CardListItemViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    override fun getItemViewType(position: Int): Int = when (getItem(position)) {
        is CardListItem.Section -> CardListItemViewType.SECTION.value
        is CardListItem.BizCard -> CardListItemViewType.CARD.value
    }

    enum class CardListItemViewType(val value: Int) {
        SECTION(0), CARD(1);

        companion object {
            fun of(num: Int): CardListItemViewType = when (num) {
                0 -> SECTION
                1 -> CARD
                else -> throw IllegalArgumentException()
            }
        }
    }
}

abstract class CardListItemViewHolder(binding: ViewBinding) :
    RecyclerView.ViewHolder(binding.root) {
    abstract fun bind(item: CardListItem)
}

class CardListItemBizCardViewHolder(
    private val binding: ListItemBizCardBinding,
    private val viewModel: MainViewModel
) : CardListItemViewHolder(binding) {
    override fun bind(item: CardListItem) {
        if (item is CardListItem.BizCard) {
            binding.root.setOnClickListener {
                viewModel.onListItemClicked(item)
            }
            binding.imageView.setImageBitmap(item.cardImage)
            binding.name.text = item.name
            binding.company.text = item.company
        }
    }
}

class CardListItemSectionViewHolder(
    private val binding: ListItemBizCardDateBinding
) : CardListItemViewHolder(binding) {

    override fun bind(item: CardListItem) {
        if (item is CardListItem.Section) {
            binding.sectionTitle.text = item.sectionTitle
        }
    }
}

private val diffCallback = object : DiffUtil.ItemCallback<CardListItem>() {
    override fun areItemsTheSame(oldItem: CardListItem, newItem: CardListItem): Boolean {
        return oldItem == newItem
    }

    override fun areContentsTheSame(oldItem: CardListItem, newItem: CardListItem): Boolean {
        return oldItem == newItem
    }
}
