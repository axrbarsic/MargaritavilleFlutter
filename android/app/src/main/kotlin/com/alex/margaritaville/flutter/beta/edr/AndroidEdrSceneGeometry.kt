package com.alex.margaritaville.flutter.beta.edr

import com.alex.margaritaville.flutter.beta.hdr.runtime.VipHdrRectPx

data class AndroidRootPixelTransform(
    val density: Float,
    val rootScreenXPx: Int,
    val rootScreenYPx: Int,
) {
    init {
        require(density.isFinite() && density > 0f) { "Density must be finite and positive" }
    }

    fun viewport(geometry: AndroidEdrGeometry): VipHdrRectPx =
        VipHdrRectPx(
            left = geometry.viewportLeft.logicalXToRootPx(),
            top = geometry.viewportTop.logicalYToRootPx(),
            right = (geometry.viewportLeft + geometry.viewportWidth).logicalXToRootPx(),
            bottom = (geometry.viewportTop + geometry.viewportHeight).logicalYToRootPx(),
        )

    fun tile(
        geometry: AndroidEdrGeometry,
        contentLeft: Double,
        contentTop: Double,
        contentWidth: Double,
        contentHeight: Double,
    ): VipHdrRectPx {
        val screenLeft = geometry.viewportLeft + contentLeft - geometry.scrollOffsetX
        val screenTop = geometry.viewportTop + contentTop - geometry.scrollOffsetY
        return VipHdrRectPx(
            left = screenLeft.logicalXToRootPx(),
            top = screenTop.logicalYToRootPx(),
            right = (screenLeft + contentWidth).logicalXToRootPx(),
            bottom = (screenTop + contentHeight).logicalYToRootPx(),
        )
    }

    private fun Double.logicalXToRootPx(): Float = (this * density - rootScreenXPx).toFloat()

    private fun Double.logicalYToRootPx(): Float = (this * density - rootScreenYPx).toFloat()
}
