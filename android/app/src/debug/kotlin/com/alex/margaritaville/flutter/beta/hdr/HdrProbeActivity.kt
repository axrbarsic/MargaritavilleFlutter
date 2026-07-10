package com.alex.margaritaville.flutter.beta.hdr

import android.app.Activity
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Gainmap
import android.graphics.Paint
import android.graphics.RectF
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.Display
import android.view.View
import android.view.WindowManager
import java.util.function.Consumer

class HdrProbeActivity : Activity() {
    private lateinit var probeView: HdrProbeView
    private val ratioListener = Consumer<Display> { display ->
        if (Build.VERSION.SDK_INT >= 34) {
            val ratio = if (display.isHdrSdrRatioAvailable) display.hdrSdrRatio else 1f
            probeView.updateHdrSdrRatio(ratio)
            Log.i(TAG, "live hdrSdrRatio=$ratio proven=${ratio > PROOF_THRESHOLD}")
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        val applied = HdrDisplayFoundation.applyProbeContract(this)
        val diagnostics = HdrDisplayFoundation.inspect(this)
        Log.i(TAG, "contract=$applied")
        Log.i(TAG, diagnostics.logLine())

        probeView = HdrProbeView(this, diagnostics)
        setContentView(probeView)

        if (Build.VERSION.SDK_INT >= 34) {
            display?.registerHdrSdrRatioChangedListener(mainExecutor, ratioListener)
        }
    }

    override fun onResume() {
        super.onResume()
        probeView.postDelayed(
            {
                val diagnostics = HdrDisplayFoundation.inspect(this)
                probeView.updateDiagnostics(diagnostics)
                val proven = diagnostics.hdrSdrRatio > PROOF_THRESHOLD
                Log.i(TAG, "settled ${diagnostics.logLine()} proven=$proven")
            },
            SETTLE_DELAY_MS,
        )
    }

    override fun onDestroy() {
        if (Build.VERSION.SDK_INT >= 34) {
            display?.unregisterHdrSdrRatioChangedListener(ratioListener)
        }
        super.onDestroy()
    }

    companion object {
        const val TAG = "MargaritaHdrProbe"
        private const val SETTLE_DELAY_MS = 1_500L
        private const val PROOF_THRESHOLD = 1.02f
    }
}

private class HdrProbeView(
    context: Activity,
    diagnostics: HdrDisplayDiagnostics,
) : View(context) {
    private var diagnostics = diagnostics
    private var liveRatio = diagnostics.hdrSdrRatio
    private val density = resources.displayMetrics.density
    private val paint = Paint(Paint.ANTI_ALIAS_FLAG)
    private val textPaint =
        Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            textSize = 17f * density
        }
    private val smallTextPaint =
        Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.rgb(190, 200, 210)
            textSize = 13f * density
        }
    private val sdrBitmap = createReferenceBitmap(withGainmap = false)
    private val hdrBitmap = createReferenceBitmap(withGainmap = true)

    init {
        setBackgroundColor(Color.BLACK)
        contentDescription = "HDR probe with SDR and gainmap HDR reference patches"
    }

    fun updateHdrSdrRatio(value: Float) {
        liveRatio = value
        invalidate()
    }

    fun updateDiagnostics(value: HdrDisplayDiagnostics) {
        diagnostics = value
        liveRatio = value.hdrSdrRatio
        invalidate()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        val margin = 20f * density
        var baseline = margin + 20f * density

        canvas.drawText("Margaritaville · Android HDR probe", margin, baseline, textPaint)
        baseline += 26f * density
        canvas.drawText(
            "HDR=${diagnostics.displayReportsHdr}  WCG=${diagnostics.wideColorGamut}  " +
                "ratio=${"%.3f".format(liveRatio)}",
            margin,
            baseline,
            smallTextPaint,
        )
        baseline += 21f * density
        canvas.drawText(
            "refresh=${"%.1f".format(diagnostics.currentRefreshRateHz)} / " +
                "${diagnostics.maximumRefreshRateHz?.let { "%.1f".format(it) }} Hz  " +
                "powerSave=${diagnostics.powerSaveMode} thermal=${diagnostics.thermalStatus}",
            margin,
            baseline,
            smallTextPaint,
        )

        val gap = 12f * density
        val top = baseline + 30f * density
        val patchWidth = (width - margin * 2f - gap) / 2f
        val patchHeight = minOf(patchWidth * 1.25f, height - top - 100f * density)
        val leftRect = RectF(margin, top, margin + patchWidth, top + patchHeight)
        val rightRect = RectF(leftRect.right + gap, top, width - margin, top + patchHeight)

        canvas.drawBitmap(sdrBitmap, null, leftRect, paint)
        canvas.drawBitmap(hdrBitmap, null, rightRect, paint)

        val labelBaseline = top + patchHeight + 28f * density
        canvas.drawText("SDR reference", leftRect.left, labelBaseline, smallTextPaint)
        canvas.drawText("Gainmap HDR ×2", rightRect.left, labelBaseline, smallTextPaint)
        val proofLines =
            if (liveRatio > 1.02f) {
                listOf("PROVEN: compositor granted", "HDR headroom above SDR white")
            } else {
                listOf("WAITING: compositor headroom", "is still at the SDR baseline")
            }
        proofLines.forEachIndexed { index, line ->
            canvas.drawText(line, margin, labelBaseline + (28f + index * 25f) * density, textPaint)
        }
    }

    private fun createReferenceBitmap(withGainmap: Boolean): Bitmap {
        val base = Bitmap.createBitmap(64, 64, Bitmap.Config.ARGB_8888)
        base.eraseColor(Color.rgb(180, 180, 180))
        if (withGainmap && Build.VERSION.SDK_INT >= 34) {
            val enhancement = Bitmap.createBitmap(1, 1, Bitmap.Config.ALPHA_8)
            enhancement.eraseColor(Color.WHITE)
            val gainmap = Gainmap(enhancement).apply {
                setRatioMin(1f, 1f, 1f)
                setRatioMax(2f, 2f, 2f)
                setGamma(1f, 1f, 1f)
                setMinDisplayRatioForHdrTransition(1f)
                setDisplayRatioForFullHdr(2f)
            }
            base.gainmap = gainmap
        }
        return base
    }
}
