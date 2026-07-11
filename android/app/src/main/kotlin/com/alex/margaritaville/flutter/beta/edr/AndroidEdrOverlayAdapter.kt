package com.alex.margaritaville.flutter.beta.edr

import android.app.Activity
import android.util.Log
import android.view.ViewGroup
import com.alex.margaritaville.flutter.beta.hdr.runtime.VipHdrCellVisual
import com.alex.margaritaville.flutter.beta.hdr.runtime.VipHdrJelly
import com.alex.margaritaville.flutter.beta.hdr.runtime.VipHdrOverlayHost
import com.alex.margaritaville.flutter.beta.hdr.runtime.VipHdrPulse
import com.alex.margaritaville.flutter.beta.hdr.runtime.VipHdrRenderPacket
import com.alex.margaritaville.flutter.beta.hdr.runtime.VipHdrScene
import com.alex.margaritaville.flutter.beta.hdr.runtime.VipHdrShapePx
import io.flutter.plugin.common.BinaryMessenger

class AndroidEdrOverlayAdapter(
    private val activity: Activity,
    binaryMessenger: BinaryMessenger,
    private val overlayHost: VipHdrOverlayHost?,
    private val maximumSignalHeadroom: Float = DEFAULT_PRODUCTION_SIGNAL_HEADROOM,
) : EdrOverlayHostApi,
    AutoCloseable {
    private val flutterApi = EdrOverlayFlutterApi(binaryMessenger)
    private val lease = AndroidEdrLease()
    private val readinessGate = AndroidEdrReadinessGate()
    private var activeTiles: List<EdrTileSnapshot> = emptyList()
    private var sceneRevision = 0L

    init {
        overlayHost?.setFramePresentedListener(::onFramePresented)
    }

    override fun configureWindow(
        surfaceSessionId: Long,
        activationId: Long,
        layoutGeneration: Long,
        contentRevision: Long,
        geometryRevision: Long,
        viewportLeft: Double,
        viewportTop: Double,
        viewportWidth: Double,
        viewportHeight: Double,
        scrollOffsetX: Double,
        scrollOffsetY: Double,
        tiles: List<EdrTileSnapshot>,
    ) {
        val configuration =
            AndroidEdrConfiguration(
                surfaceSessionId = surfaceSessionId,
                activationId = activationId,
                layoutGeneration = layoutGeneration,
                contentRevision = contentRevision,
            )
        val suppliedGeometry =
            geometry(
                surfaceSessionId,
                activationId,
                layoutGeneration,
                geometryRevision,
                viewportLeft,
                viewportTop,
                viewportWidth,
                viewportHeight,
                scrollOffsetX,
                scrollOffsetY,
            )
        val accepted = lease.configure(configuration, suppliedGeometry) ?: return
        activeTiles = tiles.filter { it.valid }
        readinessGate.await(
            AndroidEdrReadinessLease(
                surfaceSessionId = surfaceSessionId,
                activationId = activationId,
                contentRevision = contentRevision,
            ),
            beganActivation = accepted.beganActivation,
        )
        submitScene(accepted.geometry)
    }

    override fun updateWindowGeometry(
        surfaceSessionId: Long,
        activationId: Long,
        layoutGeneration: Long,
        geometryRevision: Long,
        viewportLeft: Double,
        viewportTop: Double,
        viewportWidth: Double,
        viewportHeight: Double,
        scrollOffsetX: Double,
        scrollOffsetY: Double,
    ) {
        val accepted =
            lease.updateGeometry(
                geometry(
                    surfaceSessionId,
                    activationId,
                    layoutGeneration,
                    geometryRevision,
                    viewportLeft,
                    viewportTop,
                    viewportWidth,
                    viewportHeight,
                    scrollOffsetX,
                    scrollOffsetY,
                ),
            ) ?: return
        submitScene(accepted)
    }

    override fun clearWindow(
        surfaceSessionId: Long,
        activationId: Long,
        contentRevision: Long,
    ) {
        if (!lease.clear(surfaceSessionId, activationId, contentRevision)) return
        activeTiles = emptyList()
        readinessGate.clearPending()
        overlayHost?.submit(null)
        overlayHost?.setFeatureVisible(false)
    }

    override fun close() {
        overlayHost?.close()
        readinessGate.reset()
        activeTiles = emptyList()
    }

    private fun submitScene(geometry: AndroidEdrGeometry) {
        val host = overlayHost ?: return
        val contentRoot = activity.findViewById<ViewGroup>(android.R.id.content)
        val rootLocation = IntArray(2)
        contentRoot.getLocationOnScreen(rootLocation)
        val transform =
            AndroidRootPixelTransform(
                density = activity.resources.displayMetrics.density,
                rootScreenXPx = rootLocation[0],
                rootScreenYPx = rootLocation[1],
            )
        val cells = activeTiles.mapNotNull { it.toCellVisual(geometry, transform) }
        host.setFeatureVisible(true)
        host.submit(
            VipHdrScene(
                revision = ++sceneRevision,
                viewportPx = transform.viewport(geometry),
                cells = cells,
                contentRevision = lease.activeContentRevision,
            ),
        )
    }

    private fun EdrTileSnapshot.toCellVisual(
        geometry: AndroidEdrGeometry,
        transform: AndroidRootPixelTransform,
    ): VipHdrCellVisual? {
        if (!valid) return null
        val bounds = transform.tile(geometry, left, top, width, height)
        val density = transform.density
        return VipHdrCellVisual(
            id = roomId,
            shape =
                VipHdrShapePx.RoundedRect(
                    bounds = bounds,
                    cornerRadiusPx = (cornerRadius * density).toFloat().coerceAtLeast(0f),
                ),
            baseColorArgb = baseColorArgb.toInt(),
            primaryText = roomId,
            secondaryText = timeText,
            desiredHeadroom = if (vipHdrEnabled) maximumSignalHeadroom else 1f,
            pulse = pulse(),
            jelly =
                if (vipJellyEnabled) {
                    VipHdrJelly(
                        speed = vipJellySpeed.toFloat(),
                        seed = stableSeed(roomId),
                    )
                } else {
                    null
                },
        )
    }

    private fun EdrTileSnapshot.pulse(): VipHdrPulse? {
        val generation = pulseGeneration ?: return null
        val startedAt = pulseStartedAtMicros ?: return null
        if (generation < 0 || pulseColorArgb == null || pulseBoostColorArgb == null) return null
        val elapsedMicros = (System.currentTimeMillis() * 1_000L - startedAt).coerceAtLeast(0L)
        val startedAtNanos = (System.nanoTime() - elapsedMicros * 1_000L).coerceAtLeast(0L)
        return VipHdrPulse(
            periodMillis = PULSE_DURATION_MS,
            minimumOpacity = 1f,
            startedAtNanos = startedAtNanos,
            colorArgb = pulseColorArgb?.toInt(),
            boostColorArgb = pulseBoostColorArgb?.toInt(),
            springIntensity = springIntensity.toFloat(),
        )
    }

    private fun stableSeed(value: String): Float {
        var hash = 2_166_136_261u
        value.encodeToByteArray().forEach { byte ->
            hash = (hash xor byte.toUByte().toUInt()) * 16_777_619u
        }
        return (hash and 0xFFFFu).toFloat() / 0xFFFFu.toFloat()
    }

    private fun onFramePresented(packet: VipHdrRenderPacket) {
        val contentRevision = packet.scene.contentRevision ?: return
        val readiness =
            readinessGate.consumeFirstDraw(contentRevision) {
                lease.isActive(it.surfaceSessionId, it.activationId, it.contentRevision)
            } ?: return
        flutterApi.windowReady(
            readiness.surfaceSessionId,
            readiness.activationId,
            readiness.contentRevision,
        ) { result ->
            result.exceptionOrNull()?.let { Log.w(TAG, "windowReady callback failed", it) }
        }
        Log.d(TAG, "windowReady session=${readiness.surfaceSessionId} content=$contentRevision")
    }

    private val EdrTileSnapshot.valid: Boolean
        get() =
            roomId.isNotBlank() &&
                listOf(left, top, width, height, cornerRadius, vipJellySpeed, springIntensity)
                    .all(Double::isFinite) &&
                width > 0.0 &&
                height > 0.0 &&
                cornerRadius >= 0.0

    private fun geometry(
        surfaceSessionId: Long,
        activationId: Long,
        layoutGeneration: Long,
        geometryRevision: Long,
        viewportLeft: Double,
        viewportTop: Double,
        viewportWidth: Double,
        viewportHeight: Double,
        scrollOffsetX: Double,
        scrollOffsetY: Double,
    ) =
        AndroidEdrGeometry(
            surfaceSessionId,
            activationId,
            layoutGeneration,
            geometryRevision,
            viewportLeft,
            viewportTop,
            viewportWidth,
            viewportHeight,
            scrollOffsetX,
            scrollOffsetY,
        )

    companion object {
        const val DEFAULT_PRODUCTION_WINDOW_HEADROOM = 0f
        const val DEFAULT_PRODUCTION_SIGNAL_HEADROOM = 5f
        private const val PULSE_DURATION_MS = 2_580L
        private const val TAG = "MargaritaEdrAdapter"
    }
}
