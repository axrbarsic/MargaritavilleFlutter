package com.alex.margaritaville.flutter.beta.hdr.runtime

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.os.Build
import android.view.View
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.min

class VipHdrOverlaySurface(
    context: Context,
) : View(context), VipHdrRenderSurface {
    var availabilityListener: ((Boolean) -> Unit)? = null
    var framePresentedListener: ((VipHdrRenderPacket) -> Unit)? = null

    private var packet: VipHdrRenderPacket? = null
    private var aggregatedVisible = false
    private var cachedSceneRevision: Long? = null
    private var reportedSceneRevision: Long? = null
    private var pendingCommitRevision: Long? = null
    private val pathCache = mutableMapOf<String, Path>()
    private val bitmapCache = LinkedHashMap<BitmapKey, Bitmap>(MAX_BITMAP_CACHE_ENTRIES, 0.75f, true)
    private val paint = Paint(Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG)
    private val boostPaint = Paint(Paint.ANTI_ALIAS_FLAG)
    private val labelRenderer = VipHdrLabelRenderer(context)

    init {
        setWillNotDraw(false)
        setBackgroundColor(Color.TRANSPARENT)
        isClickable = false
        isFocusable = false
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
    }

    override fun present(packet: VipHdrRenderPacket) {
        checkMainThread()
        this.packet = packet
        if (cachedSceneRevision != packet.scene.revision) {
            cachedSceneRevision = packet.scene.revision
            pathCache.clear()
        }
        postInvalidateOnAnimation()
    }

    override fun clear() {
        checkMainThread()
        if (packet == null) return
        packet = null
        postInvalidateOnAnimation()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        val currentPacket = packet ?: return
        if (Build.VERSION.SDK_INT < 34) return
        val frameTimeNanos =
            currentPacket.frameTimeNanos.takeIf { it > 0L } ?: System.nanoTime()
        val timeSeconds = frameTimeNanos / 1_000_000_000.0

        val viewport = currentPacket.scene.viewportPx
        val viewportSaveCount = canvas.save()
        canvas.clipRect(viewport.left, viewport.top, viewport.right, viewport.bottom)
        currentPacket.scene.visibleCells.forEach { cell ->
            val saveCount = canvas.save()
            applyCellTransform(canvas, cell, timeSeconds, frameTimeNanos)
            val path = cell.renderPath(timeSeconds)
            canvas.clipPath(path)
            drawBase(canvas, cell, currentPacket, frameTimeNanos)
            drawPulse(canvas, cell, currentPacket, frameTimeNanos)
            labelRenderer.draw(canvas, cell)
            canvas.restoreToCount(saveCount)
        }
        canvas.restoreToCount(viewportSaveCount)
        reportFramePresented(currentPacket)
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        notifyAvailability()
    }

    override fun onDetachedFromWindow() {
        availabilityListener?.invoke(false)
        super.onDetachedFromWindow()
    }

    override fun onVisibilityAggregated(isVisible: Boolean) {
        super.onVisibilityAggregated(isVisible)
        aggregatedVisible = isVisible
        notifyAvailability()
    }

    private fun notifyAvailability() {
        availabilityListener?.invoke(isAttachedToWindow && aggregatedVisible)
    }

    private fun hdrBitmap(
        baseColorArgb: Int,
        headroom: Float,
    ): Bitmap {
        val key = BitmapKey(baseColorArgb = baseColorArgb or 0xFF000000.toInt(), headroomCent = (headroom * 100).toInt())
        return bitmapCache[key] ?: Api34GainmapBitmapFactory.create(
            baseColorArgb = key.baseColorArgb,
            headroom = key.headroomCent / 100f,
        ).also {
            bitmapCache[key] = it
            trimBitmapCache()
        }
    }

    private fun trimBitmapCache() {
        while (bitmapCache.size > MAX_BITMAP_CACHE_ENTRIES) {
            val oldestKey = bitmapCache.entries.first().key
            // Hardware display lists may still reference the previous frame's bitmap.
            // Drop the strong reference and let Android reclaim the tiny 1x1 bitmap safely.
            bitmapCache.remove(oldestKey)
        }
    }

    private fun drawBase(
        canvas: Canvas,
        cell: VipHdrCellVisual,
        packet: VipHdrRenderPacket,
        frameTimeNanos: Long,
    ) {
        val signalHeadroom = min(cell.desiredHeadroom, packet.maximumSignalHeadroom)
        paint.alpha =
            (cell.renderOpacity(frameTimeNanos) * Color.alpha(cell.baseColorArgb))
                .toInt()
                .coerceIn(0, 255)
        canvas.drawBitmap(
            hdrBitmap(cell.baseColorArgb, signalHeadroom),
            null,
            cell.shape.bounds.toRectF(),
            paint,
        )
    }

    private fun drawPulse(
        canvas: Canvas,
        cell: VipHdrCellVisual,
        packet: VipHdrRenderPacket,
        frameTimeNanos: Long,
    ) {
        val pulse = cell.pulse ?: return
        val heat = cell.pulseHeat(frameTimeNanos)
        if (heat <= 0f || !pulse.usesDonorTimeline) return
        val boostColor = pulse.boostColorArgb ?: return
        val pulseColor = pulse.colorArgb ?: return
        boostPaint.color = boostColor
        boostPaint.alpha = (cell.opacity * heat * (1f - heat) * 255f).toInt().coerceIn(0, 255)
        canvas.drawRect(cell.shape.bounds.toRectF(), boostPaint)
        paint.alpha = (cell.opacity * heat * 255f).toInt().coerceIn(0, 255)
        canvas.drawBitmap(
            hdrBitmap(pulseColor, packet.maximumSignalHeadroom),
            null,
            cell.shape.bounds.toRectF(),
            paint,
        )
    }

    private fun applyCellTransform(
        canvas: Canvas,
        cell: VipHdrCellVisual,
        timeSeconds: Double,
        frameTimeNanos: Long,
    ) {
        val bounds = cell.shape.bounds
        val centerX = (bounds.left + bounds.right) / 2f
        val centerY = (bounds.top + bounds.bottom) / 2f
        val density = resources.displayMetrics.density
        val jellyTransform =
            cell.jelly?.let {
                VipHdrJellyGeometry.transform(timeSeconds, it.speed, it.seed, density)
            }
        val heat = cell.pulseHeat(frameTimeNanos)
        val spring = cell.pulse?.springIntensity ?: 0f
        val rubber = heat * VipHdrPulseTiming.RUBBER_AMPLITUDE_MULTIPLIER
        val pulseScale = 1f + VipHdrPulseTiming.SCALE_COEFFICIENT * spring * rubber
        val pulseOffsetY = -VipHdrPulseTiming.VERTICAL_OFFSET_DP * density * spring * rubber
        canvas.translate(
            centerX + (jellyTransform?.offsetXPx ?: 0f),
            centerY + (jellyTransform?.offsetYPx ?: 0f) + pulseOffsetY,
        )
        canvas.scale(
            (jellyTransform?.scaleX ?: 1f) * pulseScale,
            (jellyTransform?.scaleY ?: 1f) * pulseScale,
        )
        canvas.translate(-centerX, -centerY)
    }

    private fun VipHdrCellVisual.renderPath(timeSeconds: Double): Path {
        val rounded = shape as? VipHdrShapePx.RoundedRect
        val jelly = jelly
        return if (rounded != null && jelly != null) {
            VipHdrJellyGeometry.path(
                bounds = rounded.bounds,
                timeSeconds = timeSeconds,
                speed = jelly.speed,
                seed = jelly.seed,
                cornerRadiusPx = rounded.cornerRadiusPx,
                density = resources.displayMetrics.density,
            )
        } else {
            pathCache.getOrPut(id) { shape.toPath() }
        }
    }

    private fun reportFramePresented(currentPacket: VipHdrRenderPacket) {
        val revision = currentPacket.scene.revision
        if (
            !isHardwareAccelerated ||
            reportedSceneRevision == revision ||
            pendingCommitRevision == revision
        ) return
        pendingCommitRevision = revision
        val onFrameCommitted = {
            if (pendingCommitRevision == revision) pendingCommitRevision = null
            if (packet?.scene?.revision == currentPacket.scene.revision) {
                reportedSceneRevision = revision
                framePresentedListener?.invoke(currentPacket)
            }
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && viewTreeObserver.isAlive) {
            viewTreeObserver.registerFrameCommitCallback(onFrameCommitted)
        } else {
            post(onFrameCommitted)
        }
    }

    private fun VipHdrCellVisual.renderOpacity(frameTimeNanos: Long): Float {
        val pulse = pulse ?: return opacity
        if (pulse.usesDonorTimeline) return opacity
        if (frameTimeNanos <= 0L) return opacity
        val periodNanos = pulse.periodMillis * 1_000_000.0
        val normalized = ((frameTimeNanos / periodNanos) + pulse.phaseOffset) % 1.0
        val wave = ((1.0 - cos(normalized * 2.0 * PI)) * 0.5).toFloat()
        return opacity * (pulse.minimumOpacity + (1f - pulse.minimumOpacity) * wave)
    }

    private fun VipHdrCellVisual.pulseHeat(frameTimeNanos: Long): Float {
        val pulse = pulse ?: return 0f
        val startedAtNanos = pulse.startedAtNanos ?: return 0f
        val elapsedSeconds = (frameTimeNanos - startedAtNanos) / 1_000_000_000.0
        return VipHdrPulseTiming.heat(elapsedSeconds)
    }

    private fun VipHdrShapePx.toPath(): Path =
        Path().apply {
            when (this@toPath) {
                is VipHdrShapePx.RoundedRect ->
                    addRoundRect(bounds.toRectF(), cornerRadiusPx, cornerRadiusPx, Path.Direction.CW)
                is VipHdrShapePx.Polygon -> {
                    moveTo(points.first().x, points.first().y)
                    points.drop(1).forEach { lineTo(it.x, it.y) }
                    close()
                }
            }
        }

    private fun VipHdrRectPx.toRectF(): RectF = RectF(left, top, right, bottom)

    private fun checkMainThread() {
        check(android.os.Looper.myLooper() == android.os.Looper.getMainLooper()) {
            "VipHdrOverlaySurface must be used from the main thread"
        }
    }

    private data class BitmapKey(
        val baseColorArgb: Int,
        val headroomCent: Int,
    )

    companion object {
        private const val MAX_BITMAP_CACHE_ENTRIES = 32
    }
}
