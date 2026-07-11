package com.alex.margaritaville.flutter.beta.edr

data class AndroidEdrReadinessLease(
    val surfaceSessionId: Long,
    val activationId: Long,
    val contentRevision: Long,
)

class AndroidEdrReadinessGate {
    private var pending: AndroidEdrReadinessLease? = null
    private var lastDelivered: AndroidEdrReadinessLease? = null

    fun await(
        lease: AndroidEdrReadinessLease,
        beganActivation: Boolean,
    ) {
        if (beganActivation) lastDelivered = null
        pending = lease.takeUnless { it == lastDelivered }
    }

    fun consumeFirstDraw(
        contentRevision: Long,
        isLeaseActive: (AndroidEdrReadinessLease) -> Boolean,
    ): AndroidEdrReadinessLease? {
        val candidate = pending ?: return null
        if (candidate.contentRevision != contentRevision || !isLeaseActive(candidate)) return null
        pending = null
        lastDelivered = candidate
        return candidate
    }

    fun clearPending() {
        pending = null
    }

    fun reset() {
        pending = null
        lastDelivered = null
    }
}
