package com.alex.margaritaville.flutter.beta.edr

data class AndroidEdrSuppressionCommit(
    val surfaceSessionId: Long,
    val activationId: Long,
    val presentationRevision: Long,
    internal val generation: Long,
)

/** Rejects compositor callbacks that belong to an obsolete presentation. */
class AndroidEdrSuppressionCommitGate {
    private var generation = 0L
    private var pending: AndroidEdrSuppressionCommit? = null

    fun begin(
        surfaceSessionId: Long,
        activationId: Long,
        presentationRevision: Long,
    ): AndroidEdrSuppressionCommit =
        AndroidEdrSuppressionCommit(
            surfaceSessionId = surfaceSessionId,
            activationId = activationId,
            presentationRevision = presentationRevision,
            generation = ++generation,
        ).also { pending = it }

    fun complete(commit: AndroidEdrSuppressionCommit): Boolean {
        if (pending != commit || commit.generation != generation) return false
        pending = null
        return true
    }

    fun cancel(commit: AndroidEdrSuppressionCommit): Boolean {
        if (pending != commit || commit.generation != generation) return false
        pending = null
        return true
    }

    fun invalidate() {
        generation += 1
        pending = null
    }
}
