package com.alex.margaritaville.flutter.beta.edr

/** Invalidates asynchronous native callbacks when their adapter is closed. */
class AndroidEdrLifecycleGate {
    private var epoch = 0L

    var isOpen: Boolean = true
        private set

    fun capture(): Long? = epoch.takeIf { isOpen }

    fun accepts(capturedEpoch: Long): Boolean = isOpen && capturedEpoch == epoch

    fun close(): Boolean {
        if (!isOpen) return false
        isOpen = false
        epoch += 1
        return true
    }
}
