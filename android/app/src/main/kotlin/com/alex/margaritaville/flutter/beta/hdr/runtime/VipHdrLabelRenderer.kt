package com.alex.margaritaville.flutter.beta.hdr.runtime

import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Typeface

internal class VipHdrLabelRenderer(
    private val context: Context,
) {
    private val density = context.resources.displayMetrics.density
    private val paint =
        Paint(Paint.ANTI_ALIAS_FLAG or Paint.SUBPIXEL_TEXT_FLAG).apply {
            color = ROOM_FOREGROUND_ARGB
            textAlign = Paint.Align.CENTER
        }
    private val roomTypeface = loadTypeface(width = 117)
    private val timeTypeface = loadTypeface(width = 110)

    fun draw(
        canvas: Canvas,
        cell: VipHdrCellVisual,
    ) {
        val primary = cell.primaryText?.takeIf(String::isNotEmpty) ?: return
        val bounds = cell.shape.bounds
        val logicalHeight = (bounds.bottom - bounds.top) / density
        val metrics = VipHdrLabelLayout.resolve(logicalHeight)
        if (metrics.contentScale <= 0f) return
        val horizontalPadding = LABEL_HORIZONTAL_PADDING_DP * density
        val verticalPadding = metrics.verticalPaddingDp * density
        val gap = metrics.gapDp * density
        val availableWidth = bounds.right - bounds.left - horizontalPadding * 2f
        if (availableWidth <= 0f) return

        val secondary = cell.secondaryText.orEmpty()
        val timeHeight =
            if (secondary.isEmpty()) {
                0f
            } else {
                fontLineHeightPx(cell.secondaryFontSizeSp * density, timeTypeface)
            }
        val roomTop = bounds.top + verticalPadding
        val roomBottom =
            if (secondary.isEmpty()) {
                bounds.bottom - verticalPadding
            } else {
                bounds.bottom - verticalPadding - timeHeight - gap
            }

        drawFittedCenteredText(
            canvas = canvas,
            text = primary,
            centerX = (bounds.left + bounds.right) / 2f,
            centerY = (roomTop + roomBottom) / 2f,
            availableWidth = availableWidth,
            availableHeight = (roomBottom - roomTop).coerceAtLeast(1f),
            baseSizePx = cell.primaryFontSizeSp * density,
            minimumScale = 0.50f,
            typeface = roomTypeface,
        )

        if (secondary.isNotEmpty()) {
            drawFittedCenteredText(
                canvas = canvas,
                text = secondary,
                centerX = (bounds.left + bounds.right) / 2f,
                centerY = bounds.bottom - verticalPadding - timeHeight / 2f,
                availableWidth = availableWidth,
                availableHeight = timeHeight,
                baseSizePx = cell.secondaryFontSizeSp * density,
                minimumScale = 0.62f,
                typeface = timeTypeface,
            )
        }
    }

    private fun drawFittedCenteredText(
        canvas: Canvas,
        text: String,
        centerX: Float,
        centerY: Float,
        availableWidth: Float,
        availableHeight: Float,
        baseSizePx: Float,
        minimumScale: Float,
        typeface: Typeface,
    ) {
        paint.typeface = typeface
        paint.textSize = baseSizePx
        val widthScale = availableWidth / paint.measureText(text).coerceAtLeast(1f)
        val metrics = paint.fontMetrics
        val heightScale = availableHeight / (metrics.descent - metrics.ascent).coerceAtLeast(1f)
        val scale = minOf(1f, widthScale, heightScale).coerceAtLeast(minimumScale)
        paint.textSize = baseSizePx * scale
        val fittedMetrics = paint.fontMetrics
        val baseline = centerY - (fittedMetrics.ascent + fittedMetrics.descent) / 2f
        canvas.drawText(text, centerX, baseline, paint)
    }

    private fun fontLineHeightPx(
        sizePx: Float,
        typeface: Typeface,
    ): Float {
        paint.typeface = typeface
        paint.textSize = sizePx
        val metrics = paint.fontMetrics
        return (metrics.descent - metrics.ascent).coerceAtLeast(1f)
    }

    private fun loadTypeface(width: Int): Typeface =
        runCatching {
            Typeface.Builder(context.assets, FONT_ASSET_PATH)
                .setFontVariationSettings("'wght' 900, 'wdth' $width")
                .build()
        }.getOrElse { Typeface.DEFAULT_BOLD }

    private companion object {
        const val FONT_ASSET_PATH = "flutter_assets/assets/fonts/NunitoSans-Variable.ttf"
        const val ROOM_FOREGROUND_ARGB = 0xFF050505.toInt()
        const val LABEL_HORIZONTAL_PADDING_DP = 4f
    }
}
