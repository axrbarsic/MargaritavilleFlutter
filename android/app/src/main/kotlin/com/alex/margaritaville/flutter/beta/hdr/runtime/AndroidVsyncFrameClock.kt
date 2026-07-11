package com.alex.margaritaville.flutter.beta.hdr.runtime

import android.os.Looper
import android.view.Choreographer

/**
 * One vsync source can serve every continuous Android visual runtime consumer.
 * The app composition root owns exactly one instance and injects it into hosts.
 */
class AndroidVsyncFrameClock(
    private val choreographer: Choreographer = Choreographer.getInstance(),
) : VipHdrFrameClock {
    private val listeners = linkedSetOf<VipHdrFrameListener>()
    private var callbackPosted = false
    private val callback = Choreographer.FrameCallback(::dispatchFrame)

    override fun addListener(listener: VipHdrFrameListener) {
        checkMainThread()
        if (!listeners.add(listener)) return
        postCallbackIfNeeded()
    }

    override fun removeListener(listener: VipHdrFrameListener) {
        checkMainThread()
        if (!listeners.remove(listener)) return
        if (listeners.isEmpty() && callbackPosted) {
            choreographer.removeFrameCallback(callback)
            callbackPosted = false
        }
    }

    private fun dispatchFrame(frameTimeNanos: Long) {
        callbackPosted = false
        listeners.toList().forEach { it.onFrame(frameTimeNanos) }
        postCallbackIfNeeded()
    }

    private fun postCallbackIfNeeded() {
        if (listeners.isEmpty() || callbackPosted) return
        callbackPosted = true
        choreographer.postFrameCallback(callback)
    }

    private fun checkMainThread() {
        check(Looper.myLooper() == Looper.getMainLooper()) {
            "AndroidVsyncFrameClock must be used from the main thread"
        }
    }
}
