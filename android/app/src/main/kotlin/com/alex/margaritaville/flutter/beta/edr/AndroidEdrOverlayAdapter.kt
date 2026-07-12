package com.alex.margaritaville.flutter.beta.edr

import android.app.Activity
import android.util.Log
import android.view.ViewGroup
import com.alex.margaritaville.flutter.beta.hdr.runtime.VipHdrCellVisual
import com.alex.margaritaville.flutter.beta.hdr.runtime.VipHdrJelly
import com.alex.margaritaville.flutter.beta.hdr.runtime.VipHdrOverlayApi
import com.alex.margaritaville.flutter.beta.hdr.runtime.VipHdrPulse
import com.alex.margaritaville.flutter.beta.hdr.runtime.VipHdrRenderPacket
import com.alex.margaritaville.flutter.beta.hdr.runtime.VipHdrScene
import com.alex.margaritaville.flutter.beta.hdr.runtime.VipHdrShapePx
import io.flutter.plugin.common.BinaryMessenger

class AndroidEdrOverlayAdapter(
    private val activity: Activity,
    binaryMessenger: BinaryMessenger,
    private val overlayHost: VipHdrOverlayApi?,
    private val maximumSignalHeadroom: Float = DEFAULT_PRODUCTION_SIGNAL_HEADROOM,
) : EdrOverlayHostApi,
    AutoCloseable {
    private val flutterApi = EdrOverlayFlutterApi(binaryMessenger)
    private val lease = AndroidEdrLease()
    private val readinessGate = AndroidEdrReadinessGate()
    private val suppressionCommitGate = AndroidEdrSuppressionCommitGate()
    private val lifecycleGate = AndroidEdrLifecycleGate()
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
        presentationRevision: Long,
        geometryRevision: Long,
        viewportLeft: Double,
        viewportTop: Double,
        viewportWidth: Double,
        viewportHeight: Double,
        scrollOffsetX: Double,
        scrollOffsetY: Double,
        tiles: List<EdrTileSnapshot>,
    ) {
        if (!lifecycleGate.isOpen) return
        val configuration =
            AndroidEdrConfiguration(
                surfaceSessionId = surfaceSessionId,
                activationId = activationId,
                layoutGeneration = layoutGeneration,
                contentRevision = contentRevision,
                presentationRevision = presentationRevision,
            )
        val suppliedGeometry =
            geometry(
                surfaceSessionId,
                activationId,
                layoutGeneration,
                presentationRevision,
                geometryRevision,
                viewportLeft,
                viewportTop,
                viewportWidth,
                viewportHeight,
                scrollOffsetX,
                scrollOffsetY,
            )
        val accepted = lease.configure(configuration, suppliedGeometry) ?: return
        suppressionCommitGate.invalidate()
        activeTiles = tiles.filter { it.valid }
        val awaitsCommit =
            readinessGate.await(
                AndroidEdrReadinessLease(
                    surfaceSessionId = surfaceSessionId,
                    activationId = activationId,
                    contentRevision = contentRevision,
                    presentationRevision = presentationRevision,
                ),
                beganActivation = accepted.beganActivation,
            )
        if (awaitsCommit) overlayHost?.setPresentationSuppressed(true)
        submitScene(accepted.geometry)
    }

    override fun updateWindowGeometry(
        surfaceSessionId: Long,
        activationId: Long,
        layoutGeneration: Long,
        presentationRevision: Long,
        geometryRevision: Long,
        viewportLeft: Double,
        viewportTop: Double,
        viewportWidth: Double,
        viewportHeight: Double,
        scrollOffsetX: Double,
        scrollOffsetY: Double,
    ) {
        if (!lifecycleGate.isOpen) return
        val accepted =
            lease.updateGeometry(
                geometry(
                    surfaceSessionId,
                    activationId,
                    layoutGeneration,
                    presentationRevision,
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

    override fun suspendWindow(
        surfaceSessionId: Long,
        activationId: Long,
        presentationRevision: Long,
        callback: (Result<EdrPresentationAck>) -> Unit,
    ) {
        if (!lifecycleGate.isOpen ||
            !lease.suspend(surfaceSessionId, activationId, presentationRevision)
        ) {
            callback(
                Result.success(
                    EdrPresentationAck(
                        surfaceSessionId,
                        activationId,
                        presentationRevision,
                        false,
                        EdrPresentationOutcome.STALE_REJECTED,
                        0,
                        0,
                    ),
                ),
            )
            return
        }
        readinessGate.clearPending()
        val suppressionCommit =
            suppressionCommitGate.begin(
                surfaceSessionId,
                activationId,
                presentationRevision,
            )
        val host = overlayHost
        if (host == null) {
            val confirmed =
                suppressionCommitGate.complete(suppressionCommit) &&
                    lease.isPresentationActive(
                        surfaceSessionId,
                        activationId,
                        presentationRevision,
                    )
            callback(
                Result.success(
                    EdrPresentationAck(
                        surfaceSessionId,
                        activationId,
                        presentationRevision,
                        confirmed,
                        if (confirmed) {
                            EdrPresentationOutcome.NEVER_PRESENTED_FLUTTER_ONLY
                        } else {
                            EdrPresentationOutcome.STALE_REJECTED
                        },
                        0,
                        0,
                    ),
                ),
            )
            return
        }
        var callbackCompleted = false
        fun finishSuppression(frameCommitted: Boolean) {
            if (callbackCompleted) return
            callbackCompleted = true
            val currentCommit =
                if (frameCommitted) {
                    suppressionCommitGate.complete(suppressionCommit)
                } else {
                    suppressionCommitGate.cancel(suppressionCommit)
                }
            val leaseStillActive =
                lease.isPresentationActive(
                    surfaceSessionId,
                    activationId,
                    presentationRevision,
                )
            val confirmed = frameCommitted && currentCommit && leaseStillActive
            if (confirmed) host.setFeatureVisible(false)
            val presentedAtNanos = if (confirmed) System.nanoTime() else 0L
            val outcome =
                when {
                    confirmed -> EdrPresentationOutcome.TRANSPARENT_PRESENTED
                    currentCommit && !frameCommitted -> EdrPresentationOutcome.FAILED
                    else -> EdrPresentationOutcome.STALE_REJECTED
                }
            callback(
                Result.success(
                    EdrPresentationAck(
                        surfaceSessionId,
                        activationId,
                        presentationRevision,
                        confirmed,
                        outcome,
                        if (confirmed) suppressionCommit.generation else 0,
                        presentedAtNanos,
                    ),
                ),
            )
        }
        host.setPresentationSuppressed(
            suppressed = true,
            onFrameCommitted = { finishSuppression(frameCommitted = true) },
            onCommitCancelled = { finishSuppression(frameCommitted = false) },
        )
    }

    override fun clearWindow(
        surfaceSessionId: Long,
        activationId: Long,
        contentRevision: Long,
    ) {
        if (!lifecycleGate.isOpen) return
        if (!lease.clear(surfaceSessionId, activationId, contentRevision)) return
        suppressionCommitGate.invalidate()
        activeTiles = emptyList()
        readinessGate.clearPending()
        overlayHost?.setPresentationSuppressed(true)
        overlayHost?.submit(null)
        overlayHost?.setFeatureVisible(false)
    }

    override fun close() {
        if (!lifecycleGate.close()) return
        suppressionCommitGate.invalidate()
        readinessGate.reset()
        lease.reset()
        activeTiles = emptyList()
        overlayHost?.setFramePresentedListener(null)
        overlayHost?.close()
    }

    private fun submitScene(geometry: AndroidEdrGeometry) {
        if (!lifecycleGate.isOpen) return
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
                presentationRevision = lease.activePresentationRevision,
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
            primaryFontSizeSp = primaryFontSize.toFloat(),
            secondaryFontSizeSp = secondaryFontSize.toFloat(),
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
        val callbackEpoch = lifecycleGate.capture() ?: return
        val contentRevision = packet.scene.contentRevision ?: return
        val presentationRevision = packet.scene.presentationRevision ?: return
        val readiness =
            readinessGate.consumeFirstDraw(contentRevision, presentationRevision) {
                lease.isActive(
                    it.surfaceSessionId,
                    it.activationId,
                    it.contentRevision,
                    it.presentationRevision,
                )
            } ?: return
        flutterApi.windowReady(
            readiness.surfaceSessionId,
            readiness.activationId,
            readiness.contentRevision,
            readiness.presentationRevision,
        ) { result ->
            val acknowledgement = result.getOrNull()
            val accepted =
                acknowledgement?.accepted == true &&
                    acknowledgement.surfaceSessionId == readiness.surfaceSessionId &&
                    acknowledgement.activationId == readiness.activationId &&
                    acknowledgement.contentRevision == readiness.contentRevision &&
                    acknowledgement.presentationRevision == readiness.presentationRevision &&
                    lease.isActive(
                        readiness.surfaceSessionId,
                        readiness.activationId,
                        readiness.contentRevision,
                        readiness.presentationRevision,
                    )
            if (accepted && lifecycleGate.accepts(callbackEpoch)) {
                overlayHost?.setPresentationSuppressed(false)
            }
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
        presentationRevision: Long,
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
            presentationRevision,
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
