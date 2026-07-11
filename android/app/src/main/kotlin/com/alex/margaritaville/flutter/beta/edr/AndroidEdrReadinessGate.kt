package com.alex.margaritaville.flutter.beta.edr

data class AndroidEdrReadinessLease(
    val surfaceSessionId: Long,
    val activationId: Long,
    val contentRevision: Long,
    val presentationRevision: Long,
)

class AndroidEdrReadinessGate {
    private var pending: AndroidEdrReadinessLease? = null
    private var lastDelivered: AndroidEdrReadinessLease? = null
    var presentationSuppressed: Boolean = true
        private set

    fun await(
        lease: AndroidEdrReadinessLease,
        beganActivation: Boolean,
    ): Boolean {
        if (beganActivation) lastDelivered = null
        pending = lease.takeUnless { it == lastDelivered }
        if (pending != null) presentationSuppressed = true
        return pending != null
    }

    fun consumeFirstDraw(
        contentRevision: Long,
        presentationRevision: Long,
        isLeaseActive: (AndroidEdrReadinessLease) -> Boolean,
    ): AndroidEdrReadinessLease? {
        val candidate = pending ?: return null
        if (candidate.contentRevision != contentRevision ||
            candidate.presentationRevision != presentationRevision ||
            !isLeaseActive(candidate)
        ) {
            return null
        }
        pending = null
        lastDelivered = candidate
        presentationSuppressed = false
        return candidate
    }

    fun clearPending() {
        pending = null
        presentationSuppressed = true
    }

    fun reset() {
        pending = null
        lastDelivered = null
        presentationSuppressed = true
    }
}
