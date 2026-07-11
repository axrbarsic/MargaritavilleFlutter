package com.alex.margaritaville.flutter.beta.hdr.runtime

import android.app.Activity
import android.app.Application
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.util.Log
import android.view.Display
import android.view.ViewGroup
import com.alex.margaritaville.flutter.beta.hdr.HdrDisplayDiagnostics
import com.alex.margaritaville.flutter.beta.hdr.HdrDisplayFoundation
import com.alex.margaritaville.flutter.beta.hdr.HdrWindowPolicy
import com.alex.margaritaville.flutter.beta.hdr.HdrWindowRequest
import java.util.function.Consumer

interface VipHdrOverlayApi : AutoCloseable {
    val snapshot: VipHdrRuntimeSnapshot

    fun submit(scene: VipHdrScene?)

    fun setFeatureVisible(visible: Boolean)
}

class VipHdrOverlayHost(
    private val activity: Activity,
    frameClock: VipHdrFrameClock,
    requestedHeadroom: Float = HdrDisplayFoundation.DEFAULT_REQUESTED_HEADROOM,
    maximumSignalHeadroom: Float = if (requestedHeadroom == 0f) 4f else requestedHeadroom,
) : VipHdrOverlayApi,
    Application.ActivityLifecycleCallbacks {
    private val diagnostics: HdrDisplayDiagnostics
    private val runtime: VipHdrRuntime
    private val surface: VipHdrOverlaySurface
    private var closed = false
    private var ratioListenerRegistered = false
    private val logHandler = Handler(Looper.getMainLooper())
    private var pendingLoggedHdrRatio = 1f
    private val logSettledHdrRatio =
        Runnable {
            if (!closed) {
                Log.i(TAG, "hdrSdrRatio=$pendingLoggedHdrRatio status=${runtime.snapshot.status}")
            }
        }
    private val ratioListener = Consumer<Display>(::onHdrSdrRatioChanged)

    init {
        checkMainThread()
        val applied =
            HdrDisplayFoundation.applyWindowContract(
                activity,
                HdrWindowRequest(
                    desiredHeadroom = requestedHeadroom,
                    preferMaximumRefreshRate = true,
                ),
            )
        diagnostics = HdrDisplayFoundation.inspect(activity)
        val animationAllowed =
            !diagnostics.powerSaveMode &&
                (diagnostics.thermalStatus ?: PowerManager.THERMAL_STATUS_NONE) <
                PowerManager.THERMAL_STATUS_SEVERE
        runtime =
            VipHdrRuntime(
                frameClock = frameClock,
                capabilities =
                    VipHdrRuntimeCapabilities(
                        hdrUiToolkitSupported = applied.hdrWindowRequested,
                        animationAllowed = animationAllowed,
                        requestedHeadroom = maximumSignalHeadroom,
                    ),
            )
        surface = VipHdrOverlaySurface(activity)
        surface.availabilityListener = runtime::setSurfaceAvailable
        runtime.attachSurface(surface)
        runtime.updateGrantedHeadroom(diagnostics.hdrSdrRatio)

        val contentRoot = activity.findViewById<ViewGroup>(android.R.id.content)
        contentRoot.addView(
            surface,
            ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT,
            ),
        )
        activity.application.registerActivityLifecycleCallbacks(this)
        if (
            HdrWindowPolicy.shouldObserveHdrSdrRatio(
                sdkInt = Build.VERSION.SDK_INT,
                ratioAvailable = activity.display?.isHdrSdrRatioAvailable == true,
            )
        ) {
            activity.display?.registerHdrSdrRatioChangedListener(activity.mainExecutor, ratioListener)
            ratioListenerRegistered = true
        }
        Log.i(TAG, "installed contract=$applied ${diagnostics.logLine()}")
    }

    override val snapshot: VipHdrRuntimeSnapshot
        get() = runtime.snapshot

    fun setFramePresentedListener(listener: ((VipHdrRenderPacket) -> Unit)?) {
        checkMainThread()
        checkOpen()
        surface.framePresentedListener = listener
    }

    override fun submit(scene: VipHdrScene?) {
        checkMainThread()
        checkOpen()
        runtime.updateScene(scene)
    }

    override fun setFeatureVisible(visible: Boolean) {
        checkMainThread()
        checkOpen()
        runtime.setViewportVisible(visible)
    }

    override fun close() {
        checkMainThread()
        if (closed) return
        closed = true
        if (Build.VERSION.SDK_INT >= 34 && ratioListenerRegistered) {
            activity.display?.unregisterHdrSdrRatioChangedListener(ratioListener)
            ratioListenerRegistered = false
        }
        logHandler.removeCallbacks(logSettledHdrRatio)
        activity.application.unregisterActivityLifecycleCallbacks(this)
        surface.availabilityListener = null
        surface.framePresentedListener = null
        runtime.detachSurface(surface)
        runtime.close()
        (surface.parent as? ViewGroup)?.removeView(surface)
        Log.i(TAG, "closed")
    }

    override fun onActivityResumed(target: Activity) {
        if (target === activity && !closed) runtime.setHostResumed(true)
    }

    override fun onActivityPaused(target: Activity) {
        if (target === activity && !closed) runtime.setHostResumed(false)
    }

    override fun onActivityDestroyed(target: Activity) {
        if (target === activity && !closed) close()
    }

    override fun onActivityCreated(
        activity: Activity,
        savedInstanceState: Bundle?,
    ) = Unit

    override fun onActivityStarted(activity: Activity) = Unit

    override fun onActivityStopped(activity: Activity) = Unit

    override fun onActivitySaveInstanceState(
        activity: Activity,
        outState: Bundle,
    ) = Unit

    private fun onHdrSdrRatioChanged(display: Display) {
        if (closed || Build.VERSION.SDK_INT < 34) return
        val ratio = if (display.isHdrSdrRatioAvailable) display.hdrSdrRatio else 1f
        runtime.updateGrantedHeadroom(ratio)
        pendingLoggedHdrRatio = ratio
        logHandler.removeCallbacks(logSettledHdrRatio)
        logHandler.postDelayed(logSettledHdrRatio, HDR_RATIO_LOG_SETTLE_MS)
    }

    private fun checkOpen() {
        check(!closed) { "VipHdrOverlayHost is closed" }
    }

    private fun checkMainThread() {
        check(Looper.myLooper() == Looper.getMainLooper()) {
            "VipHdrOverlayHost must be used from the main thread"
        }
    }

    companion object {
        const val TAG = "MargaritaVipHdr"
        private const val HDR_RATIO_LOG_SETTLE_MS = 250L
    }
}
