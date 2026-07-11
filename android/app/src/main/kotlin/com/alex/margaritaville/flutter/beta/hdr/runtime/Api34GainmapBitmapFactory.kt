package com.alex.margaritaville.flutter.beta.hdr.runtime

import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.Gainmap
import androidx.annotation.RequiresApi

@RequiresApi(34)
internal object Api34GainmapBitmapFactory {
    fun create(
        baseColorArgb: Int,
        headroom: Float,
    ): Bitmap {
        val base = Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888)
        base.eraseColor(baseColorArgb)
        val enhancement = Bitmap.createBitmap(1, 1, Bitmap.Config.ALPHA_8)
        enhancement.eraseColor(Color.WHITE)
        base.gainmap =
            Gainmap(enhancement).apply {
                setRatioMin(1f, 1f, 1f)
                setRatioMax(headroom, headroom, headroom)
                setGamma(1f, 1f, 1f)
                setMinDisplayRatioForHdrTransition(1f)
                setDisplayRatioForFullHdr(headroom)
            }
        return base
    }
}
