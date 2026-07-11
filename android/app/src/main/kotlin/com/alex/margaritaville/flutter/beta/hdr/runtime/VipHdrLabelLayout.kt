package com.alex.margaritaville.flutter.beta.hdr.runtime

internal data class VipHdrLabelMetrics(
    val contentScale: Float,
    val primaryFontSizeSp: Float,
    val secondaryFontSizeSp: Float,
    val verticalPaddingDp: Float,
    val gapDp: Float,
)

internal object VipHdrLabelLayout {
    const val DONOR_TILE_HEIGHT_DP = 98f

    fun resolve(logicalHeight: Float): VipHdrLabelMetrics {
        val scale = (logicalHeight / DONOR_TILE_HEIGHT_DP).coerceIn(0f, 1f)
        return VipHdrLabelMetrics(
            contentScale = scale,
            primaryFontSizeSp = 44f * scale,
            secondaryFontSizeSp = 16f * scale,
            verticalPaddingDp = 10f * scale,
            gapDp = 6f * scale,
        )
    }
}
