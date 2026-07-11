package com.alex.margaritaville.flutter.beta.edr

data class AndroidEdrGeometry(
    val surfaceSessionId: Long,
    val activationId: Long,
    val layoutGeneration: Long,
    val revision: Long,
    val viewportLeft: Double,
    val viewportTop: Double,
    val viewportWidth: Double,
    val viewportHeight: Double,
    val scrollOffsetX: Double,
    val scrollOffsetY: Double,
) {
    val valid: Boolean
        get() =
            surfaceSessionId >= 0 &&
                activationId > 0 &&
                layoutGeneration >= 0 &&
                revision >= 0 &&
                listOf(
                    viewportLeft,
                    viewportTop,
                    viewportWidth,
                    viewportHeight,
                    scrollOffsetX,
                    scrollOffsetY,
                ).all(Double::isFinite) &&
                viewportWidth > 0.0 &&
                viewportHeight > 0.0
}

data class AndroidEdrConfiguration(
    val surfaceSessionId: Long,
    val activationId: Long,
    val layoutGeneration: Long,
    val contentRevision: Long,
) {
    val valid: Boolean
        get() =
            surfaceSessionId >= 0 &&
                activationId > 0 &&
                layoutGeneration >= 0 &&
                contentRevision >= 0
}

data class AcceptedAndroidEdrConfiguration(
    val geometry: AndroidEdrGeometry,
    val beganActivation: Boolean,
)

/** Mirrors the activation/session/layout ordering used by the iOS window runtime. */
class AndroidEdrLease {
    var activeSessionId: Long? = null
        private set
    var activeActivationId: Long? = null
        private set
    var activeLayoutGeneration: Long = -1
        private set
    var activeContentRevision: Long = -1
        private set
    var highestActivationId: Long = 0
        private set
    var currentGeometry: AndroidEdrGeometry? = null
        private set
    var pendingGeometry: AndroidEdrGeometry? = null
        private set

    fun configure(
        configuration: AndroidEdrConfiguration,
        suppliedGeometry: AndroidEdrGeometry,
    ): AcceptedAndroidEdrConfiguration? {
        if (!configuration.valid || !suppliedGeometry.valid) return null
        if (configuration.surfaceSessionId != suppliedGeometry.surfaceSessionId ||
            configuration.activationId != suppliedGeometry.activationId ||
            configuration.layoutGeneration != suppliedGeometry.layoutGeneration
        ) {
            return null
        }

        val beganActivation = activate(configuration.surfaceSessionId, configuration.activationId)
            ?: return null
        if (configuration.layoutGeneration < activeLayoutGeneration ||
            configuration.contentRevision < activeContentRevision
        ) {
            return null
        }

        if (configuration.layoutGeneration > activeLayoutGeneration) {
            currentGeometry = null
        }
        activeLayoutGeneration = configuration.layoutGeneration
        activeContentRevision = configuration.contentRevision

        val matchingPending =
            pendingGeometry?.takeIf {
                it.surfaceSessionId == configuration.surfaceSessionId &&
                    it.activationId == configuration.activationId &&
                    it.layoutGeneration == configuration.layoutGeneration
            }
        val candidates = listOfNotNull(currentGeometry, suppliedGeometry, matchingPending)
        val selectedGeometry = candidates.maxBy(AndroidEdrGeometry::revision)
        currentGeometry = selectedGeometry
        if (matchingPending != null) pendingGeometry = null
        return AcceptedAndroidEdrConfiguration(selectedGeometry, beganActivation)
    }

    /** Returns geometry for the geometry-only fast path, or null when stored/rejected. */
    fun updateGeometry(geometry: AndroidEdrGeometry): AndroidEdrGeometry? {
        if (!geometry.valid) return null
        val belongsToActiveLease =
            geometry.surfaceSessionId == activeSessionId &&
                geometry.activationId == activeActivationId &&
                geometry.layoutGeneration == activeLayoutGeneration
        if (belongsToActiveLease) {
            if (geometry.revision <= (currentGeometry?.revision ?: -1)) return null
            currentGeometry = geometry
            return geometry
        }

        val belongsToFutureActiveLayout =
            geometry.surfaceSessionId == activeSessionId &&
                geometry.activationId == activeActivationId &&
                geometry.layoutGeneration > activeLayoutGeneration
        if (geometry.activationId <= highestActivationId && !belongsToFutureActiveLayout) {
            return null
        }
        val pending = pendingGeometry
        if (pending != null && !geometry.isNewerThan(pending)) return null
        pendingGeometry = geometry
        return null
    }

    fun clear(
        surfaceSessionId: Long,
        activationId: Long,
        contentRevision: Long,
    ): Boolean {
        if (surfaceSessionId < 0 || activationId <= 0 || contentRevision < 0) return false
        if (surfaceSessionId != activeSessionId ||
            activationId != activeActivationId ||
            contentRevision < activeContentRevision
        ) {
            return false
        }
        if (pendingGeometry?.activationId == activationId) pendingGeometry = null
        activeSessionId = null
        activeActivationId = null
        activeLayoutGeneration = -1
        activeContentRevision = -1
        currentGeometry = null
        return true
    }

    fun isActive(
        surfaceSessionId: Long,
        activationId: Long,
        contentRevision: Long,
    ): Boolean =
        activeSessionId == surfaceSessionId &&
            activeActivationId == activationId &&
            activeContentRevision == contentRevision

    private fun activate(
        surfaceSessionId: Long,
        activationId: Long,
    ): Boolean? {
        if (activationId < highestActivationId) return null
        if (activationId == highestActivationId) {
            return if (activeSessionId == surfaceSessionId && activeActivationId == activationId) {
                false
            } else {
                null
            }
        }
        highestActivationId = activationId
        activeSessionId = surfaceSessionId
        activeActivationId = activationId
        activeLayoutGeneration = -1
        activeContentRevision = -1
        currentGeometry = null
        return true
    }

    private fun AndroidEdrGeometry.isNewerThan(other: AndroidEdrGeometry): Boolean =
        when {
            activationId != other.activationId -> activationId > other.activationId
            layoutGeneration != other.layoutGeneration -> layoutGeneration > other.layoutGeneration
            else -> revision > other.revision
        }
}
