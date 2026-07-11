package com.alex.margaritaville.flutter.beta.hdr.runtime

fun interface VipHdrFrameListener {
    fun onFrame(frameTimeNanos: Long)
}

interface VipHdrFrameClock {
    fun addListener(listener: VipHdrFrameListener)

    fun removeListener(listener: VipHdrFrameListener)
}

data class VipHdrRuntimeCapabilities(
    val hdrUiToolkitSupported: Boolean,
    val animationAllowed: Boolean,
    val requestedHeadroom: Float,
) {
    init {
        require(requestedHeadroom.isFinite() && requestedHeadroom in 1f..10_000f) {
            "Requested headroom must be within [1, 10000]"
        }
    }
}

data class VipHdrRenderPacket(
    val scene: VipHdrScene,
    val frameTimeNanos: Long,
    val grantedHeadroom: Float,
    val maximumSignalHeadroom: Float,
)

interface VipHdrRenderSurface {
    fun present(packet: VipHdrRenderPacket)

    fun clear()
}

enum class VipHdrRuntimeStatus {
    UNSUPPORTED,
    DETACHED,
    PAUSED,
    OFFSCREEN,
    IDLE,
    ACTIVE_STATIC,
    ACTIVE_ANIMATED,
    CLOSED,
}

data class VipHdrRuntimeSnapshot(
    val status: VipHdrRuntimeStatus,
    val sceneRevision: Long?,
    val visibleCellCount: Int,
    val grantedHeadroom: Float,
    val clockSubscribed: Boolean,
)

class VipHdrRuntime(
    private val frameClock: VipHdrFrameClock,
    private val capabilities: VipHdrRuntimeCapabilities,
) : AutoCloseable {
    private var surface: VipHdrRenderSurface? = null
    private var scene: VipHdrScene? = null
    private var surfaceAvailable = false
    private var hostResumed = false
    private var viewportVisible = true
    private var grantedHeadroom = 1f
    private var clockSubscribed = false
    private var closed = false
    private val frameListener = VipHdrFrameListener(::onFrame)

    val snapshot: VipHdrRuntimeSnapshot
        get() {
            val visibleCells = scene?.visibleCells.orEmpty()
            return VipHdrRuntimeSnapshot(
                status = resolveStatus(visibleCells),
                sceneRevision = scene?.revision,
                visibleCellCount = visibleCells.size,
                grantedHeadroom = grantedHeadroom,
                clockSubscribed = clockSubscribed,
            )
        }

    fun attachSurface(value: VipHdrRenderSurface) {
        checkOpen()
        check(surface == null) { "VipHdrRuntime supports exactly one render surface" }
        surface = value
        reconcile()
    }

    fun detachSurface(value: VipHdrRenderSurface) {
        checkOpen()
        if (surface !== value) return
        unsubscribeClock()
        value.clear()
        surface = null
        surfaceAvailable = false
    }

    fun updateScene(value: VipHdrScene?) {
        checkOpen()
        scene = value
        reconcile()
    }

    fun setSurfaceAvailable(value: Boolean) {
        checkOpen()
        if (surfaceAvailable == value) return
        surfaceAvailable = value
        reconcile()
    }

    fun setHostResumed(value: Boolean) {
        checkOpen()
        if (hostResumed == value) return
        hostResumed = value
        reconcile()
    }

    fun setViewportVisible(value: Boolean) {
        checkOpen()
        if (viewportVisible == value) return
        viewportVisible = value
        reconcile()
    }

    fun updateGrantedHeadroom(value: Float) {
        checkOpen()
        val normalized = if (value.isFinite()) value.coerceAtLeast(1f) else 1f
        if (grantedHeadroom == normalized) return
        grantedHeadroom = normalized
        presentStaticFrameIfPossible()
    }

    override fun close() {
        if (closed) return
        closed = true
        unsubscribeClock()
        surface?.clear()
        surface = null
        scene = null
    }

    private fun reconcile() {
        val visibleCells = scene?.visibleCells.orEmpty()
        val status = resolveStatus(visibleCells)
        val needsClock =
            status == VipHdrRuntimeStatus.ACTIVE_ANIMATED && capabilities.animationAllowed

        if (needsClock) subscribeClock() else unsubscribeClock()

        if (status == VipHdrRuntimeStatus.ACTIVE_STATIC ||
            status == VipHdrRuntimeStatus.ACTIVE_ANIMATED
        ) {
            presentStaticFrameIfPossible()
        } else {
            surface?.clear()
        }
    }

    private fun presentStaticFrameIfPossible() {
        val currentScene = scene ?: return
        if (!canPresent(currentScene.visibleCells)) return
        surface?.present(
            VipHdrRenderPacket(
                scene = currentScene,
                frameTimeNanos = 0L,
                grantedHeadroom = grantedHeadroom,
                maximumSignalHeadroom = capabilities.requestedHeadroom,
            ),
        )
    }

    private fun onFrame(frameTimeNanos: Long) {
        val currentScene = scene ?: return
        if (!canPresent(currentScene.visibleCells)) return
        surface?.present(
            VipHdrRenderPacket(
                scene = currentScene,
                frameTimeNanos = frameTimeNanos,
                grantedHeadroom = grantedHeadroom,
                maximumSignalHeadroom = capabilities.requestedHeadroom,
            ),
        )
    }

    private fun resolveStatus(visibleCells: List<VipHdrCellVisual>): VipHdrRuntimeStatus =
        when {
            closed -> VipHdrRuntimeStatus.CLOSED
            !capabilities.hdrUiToolkitSupported -> VipHdrRuntimeStatus.UNSUPPORTED
            surface == null || !surfaceAvailable -> VipHdrRuntimeStatus.DETACHED
            !hostResumed -> VipHdrRuntimeStatus.PAUSED
            !viewportVisible -> VipHdrRuntimeStatus.OFFSCREEN
            scene == null || visibleCells.isEmpty() -> VipHdrRuntimeStatus.IDLE
            capabilities.animationAllowed && scene?.hasVisibleAnimation == true ->
                VipHdrRuntimeStatus.ACTIVE_ANIMATED
            else -> VipHdrRuntimeStatus.ACTIVE_STATIC
        }

    private fun canPresent(visibleCells: List<VipHdrCellVisual>): Boolean =
        capabilities.hdrUiToolkitSupported &&
            surface != null &&
            surfaceAvailable &&
            hostResumed &&
            viewportVisible &&
            visibleCells.isNotEmpty()

    private fun subscribeClock() {
        if (clockSubscribed) return
        clockSubscribed = true
        frameClock.addListener(frameListener)
    }

    private fun unsubscribeClock() {
        if (!clockSubscribed) return
        clockSubscribed = false
        frameClock.removeListener(frameListener)
    }

    private fun checkOpen() {
        check(!closed) { "VipHdrRuntime is closed" }
    }
}
