package com.alex.margaritaville.flutter.beta.hdr

import android.app.Activity
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.os.Bundle
import android.util.Log
import android.view.View
import android.view.WindowManager
import com.alex.margaritaville.flutter.beta.hdr.runtime.AndroidVsyncFrameClock
import com.alex.margaritaville.flutter.beta.hdr.runtime.VipHdrCellVisual
import com.alex.margaritaville.flutter.beta.hdr.runtime.VipHdrOverlayHost
import com.alex.margaritaville.flutter.beta.hdr.runtime.VipHdrPointPx
import com.alex.margaritaville.flutter.beta.hdr.runtime.VipHdrPulse
import com.alex.margaritaville.flutter.beta.hdr.runtime.VipHdrRectPx
import com.alex.margaritaville.flutter.beta.hdr.runtime.VipHdrScene
import com.alex.margaritaville.flutter.beta.hdr.runtime.VipHdrShapePx

class HdrProbeActivity : Activity() {
    private lateinit var backgroundView: ProbeBackgroundView
    private lateinit var overlayHost: VipHdrOverlayHost
    private var windowHeadroomRequest = 0f
    private var signalHeadroom = 5f

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        windowHeadroomRequest =
            intent.getFloatExtra(EXTRA_WINDOW_HEADROOM, 0f).takeIf {
                it.isFinite() && (it == 0f || it in 1f..10_000f)
            } ?: 0f
        signalHeadroom =
            intent.getFloatExtra(
                EXTRA_SIGNAL_HEADROOM,
                if (windowHeadroomRequest == 0f) 5f else windowHeadroomRequest,
            ).takeIf { it.isFinite() && it in 1f..10_000f } ?: 5f

        backgroundView =
            ProbeBackgroundView(
                context = this,
                windowHeadroomRequest = windowHeadroomRequest,
                signalHeadroom = signalHeadroom,
                onGeometryChanged = ::submitScene,
            )
        setContentView(backgroundView)
        overlayHost =
            VipHdrOverlayHost(
                activity = this,
                frameClock = AndroidVsyncFrameClock(),
                requestedHeadroom = windowHeadroomRequest,
                maximumSignalHeadroom = signalHeadroom,
            )
    }

    override fun onResume() {
        super.onResume()
        backgroundView.postDelayed(
            {
                val diagnostics = HdrDisplayFoundation.inspect(this)
                backgroundView.updateDiagnostics(diagnostics)
                Log.i(
                    TAG,
                    "settled request=$windowHeadroomRequest signal=$signalHeadroom " +
                        "${diagnostics.logLine()} runtime=${overlayHost.snapshot}",
                )
            },
            SETTLE_DELAY_MS,
        )
    }

    override fun onDestroy() {
        if (::overlayHost.isInitialized) overlayHost.close()
        super.onDestroy()
    }

    private fun submitScene(geometry: ProbeGeometry) {
        if (!::overlayHost.isInitialized) return
        val jaggedShape = geometry.hdrRect.toJaggedPolygon(notchPx = 9f * backgroundView.density)
        overlayHost.submit(
            VipHdrScene(
                revision = geometry.revision,
                viewportPx = geometry.viewport,
                cells =
                    listOf(
                        VipHdrCellVisual(
                            id = "gainmap-hdr-reference",
                            shape = jaggedShape,
                            baseColorArgb = Color.rgb(180, 180, 180),
                            desiredHeadroom = signalHeadroom,
                        ),
                        VipHdrCellVisual(
                            id = "shared-vsync-pulse",
                            shape =
                                VipHdrShapePx.RoundedRect(
                                    bounds = geometry.pulseRect,
                                    cornerRadiusPx = 12f * backgroundView.density,
                                ),
                            baseColorArgb = Color.rgb(0, 210, 170),
                            desiredHeadroom = 1.5f,
                            opacity = 0.85f,
                            pulse =
                                VipHdrPulse(
                                    periodMillis = 1_400,
                                    minimumOpacity = 0.35f,
                                ),
                        ),
                    ),
            ),
        )
    }

    private fun VipHdrRectPx.toJaggedPolygon(notchPx: Float): VipHdrShapePx.Polygon {
        val midX = (left + right) / 2f
        val midY = (top + bottom) / 2f
        return VipHdrShapePx.Polygon(
            points =
                listOf(
                    VipHdrPointPx(left, top),
                    VipHdrPointPx(midX - notchPx, top),
                    VipHdrPointPx(midX, top + notchPx),
                    VipHdrPointPx(midX + notchPx, top),
                    VipHdrPointPx(right, top),
                    VipHdrPointPx(right, midY - notchPx),
                    VipHdrPointPx(right - notchPx, midY),
                    VipHdrPointPx(right, midY + notchPx),
                    VipHdrPointPx(right, bottom),
                    VipHdrPointPx(left, bottom),
                ),
        )
    }

    companion object {
        const val TAG = "MargaritaHdrProbe"
        const val EXTRA_WINDOW_HEADROOM = "windowHeadroom"
        const val EXTRA_SIGNAL_HEADROOM = "signalHeadroom"
        private const val SETTLE_DELAY_MS = 1_500L
    }
}

private data class ProbeGeometry(
    val revision: Long,
    val viewport: VipHdrRectPx,
    val sdrRect: RectF,
    val hdrRect: VipHdrRectPx,
    val pulseRect: VipHdrRectPx,
)

private class ProbeBackgroundView(
    context: Activity,
    private val windowHeadroomRequest: Float,
    private val signalHeadroom: Float,
    private val onGeometryChanged: (ProbeGeometry) -> Unit,
) : View(context) {
    val density = resources.displayMetrics.density
    private var diagnostics = HdrDisplayFoundation.inspect(context)
    private var geometry: ProbeGeometry? = null
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
    private val sdrPaint = Paint().apply { color = Color.rgb(180, 180, 180) }

    init {
        setBackgroundColor(Color.BLACK)
        contentDescription = "Production VIP HDR runtime probe"
    }

    fun updateDiagnostics(value: HdrDisplayDiagnostics) {
        diagnostics = value
        invalidate()
    }

    override fun onSizeChanged(
        width: Int,
        height: Int,
        oldWidth: Int,
        oldHeight: Int,
    ) {
        super.onSizeChanged(width, height, oldWidth, oldHeight)
        if (width <= 0 || height <= 0) return
        val margin = 20f * density
        val gap = 12f * density
        val top = 125f * density
        val patchWidth = (width - margin * 2f - gap) / 2f
        val patchHeight = minOf(patchWidth * 1.25f, height - top - 170f * density)
        val sdrRect = RectF(margin, top, margin + patchWidth, top + patchHeight)
        val hdrRect = VipHdrRectPx(sdrRect.right + gap, top, width - margin, top + patchHeight)
        val pulseRect =
            VipHdrRectPx(
                left = hdrRect.left + 18f * density,
                top = hdrRect.bottom - 54f * density,
                right = hdrRect.right - 18f * density,
                bottom = hdrRect.bottom - 18f * density,
            )
        geometry =
            ProbeGeometry(
                revision = System.nanoTime(),
                viewport = VipHdrRectPx(0f, 0f, width.toFloat(), height.toFloat()),
                sdrRect = sdrRect,
                hdrRect = hdrRect,
                pulseRect = pulseRect,
            ).also(onGeometryChanged)
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        val margin = 20f * density
        var baseline = 40f * density
        canvas.drawText("Margaritaville · production HDR runtime", margin, baseline, textPaint)
        baseline += 26f * density
        canvas.drawText(
            "HDR=${diagnostics.displayReportsHdr} WCG=${diagnostics.wideColorGamut} " +
                "ratio=${"%.3f".format(diagnostics.hdrSdrRatio)}",
            margin,
            baseline,
            smallTextPaint,
        )
        baseline += 21f * density
        canvas.drawText(
            "refresh=${"%.1f".format(diagnostics.currentRefreshRateHz)} / " +
                "${diagnostics.maximumRefreshRateHz?.let { "%.1f".format(it) }} Hz " +
                "powerSave=${diagnostics.powerSaveMode} thermal=${diagnostics.thermalStatus}",
            margin,
            baseline,
            smallTextPaint,
        )
        canvas.drawText(
            "windowRequest=$windowHeadroomRequest signal=$signalHeadroom",
            margin,
            baseline + 21f * density,
            smallTextPaint,
        )

        geometry?.let { current ->
            canvas.drawRect(current.sdrRect, sdrPaint)
            val labelY = current.sdrRect.bottom + 28f * density
            canvas.drawText("SDR reference", current.sdrRect.left, labelY, smallTextPaint)
            canvas.drawText("VIP HDR surface ×2", current.hdrRect.left, labelY, smallTextPaint)
            canvas.drawText("One surface · one shared vsync clock", margin, labelY + 34f * density, textPaint)
            canvas.drawText("Lifecycle/offscreen pause is runtime-owned", margin, labelY + 60f * density, smallTextPaint)
        }
    }
}
