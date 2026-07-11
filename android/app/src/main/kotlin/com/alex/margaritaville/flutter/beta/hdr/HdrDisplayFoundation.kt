package com.alex.margaritaville.flutter.beta.hdr

import android.app.Activity
import android.content.pm.ActivityInfo
import android.os.Build
import android.os.PowerManager
import android.view.Display
import kotlin.math.abs

data class DisplayModeCandidate(
    val id: Int,
    val width: Int,
    val height: Int,
    val refreshRateHz: Float,
)

object DisplayRefreshPolicy {
    fun maximumRateForCurrentResolution(
        currentWidth: Int,
        currentHeight: Int,
        modes: List<DisplayModeCandidate>,
    ): Float? =
        modes
            .asSequence()
            .filter { it.width == currentWidth && it.height == currentHeight }
            .map { it.refreshRateHz }
            .filter { it.isFinite() && it > 0f }
            .maxOrNull()
}

data class HdrWindowDecision(
    val shouldRequestHdrWindow: Boolean,
    val shouldRequestHeadroom: Boolean,
)

object HdrWindowPolicy {
    fun decide(
        sdkInt: Int,
        displayReportsHdr: Boolean,
    ): HdrWindowDecision =
        HdrWindowDecision(
            // Android officially added HDR rendering to the UI toolkit in API 34.
            shouldRequestHdrWindow = sdkInt >= 34 && displayReportsHdr,
            shouldRequestHeadroom = sdkInt >= 35 && displayReportsHdr,
        )

    fun shouldObserveHdrSdrRatio(
        sdkInt: Int,
        ratioAvailable: Boolean,
    ): Boolean = sdkInt >= 34 && ratioAvailable
}

data class HdrDisplayDiagnostics(
    val sdkInt: Int,
    val displayName: String,
    val displayReportsHdr: Boolean,
    val wideColorGamut: Boolean,
    val hdrTypes: List<String>,
    val maxLuminanceNits: Float,
    val maxAverageLuminanceNits: Float,
    val minLuminanceNits: Float,
    val hdrSdrRatioAvailable: Boolean,
    val hdrSdrRatio: Float,
    val currentRefreshRateHz: Float,
    val maximumRefreshRateHz: Float?,
    val supportedRefreshRatesHz: List<Float>,
    val powerSaveMode: Boolean,
    val thermalStatus: Int?,
) {
    fun logLine(): String =
        buildString {
            append("sdk=").append(sdkInt)
            append(" display=").append(displayName)
            append(" hdr=").append(displayReportsHdr)
            append(" wideGamut=").append(wideColorGamut)
            append(" hdrTypes=").append(hdrTypes)
            append(" luminanceNits=")
            append("[").append(minLuminanceNits).append("..")
            append(maxAverageLuminanceNits).append(" avg/")
            append(maxLuminanceNits).append(" max]")
            append(" hdrSdrRatio=")
            append(if (hdrSdrRatioAvailable) hdrSdrRatio else "unavailable")
            append(" refreshHz=").append(currentRefreshRateHz)
            append(" maxHz=").append(maximumRefreshRateHz)
            append(" modesHz=").append(supportedRefreshRatesHz)
            append(" powerSave=").append(powerSaveMode)
            append(" thermal=").append(thermalStatus)
        }
}

data class AppliedHdrWindowContract(
    val hdrWindowRequested: Boolean,
    val desiredHeadroom: Float?,
    val preferredRefreshRateHz: Float?,
)

data class HdrWindowRequest(
    val desiredHeadroom: Float = HdrDisplayFoundation.DEFAULT_REQUESTED_HEADROOM,
    val preferMaximumRefreshRate: Boolean = true,
) {
    init {
        require(desiredHeadroom == 0f || desiredHeadroom in 1f..10_000f) {
            "desiredHeadroom must be 0 or within [1, 10000]"
        }
    }
}

object HdrDisplayFoundation {
    const val DEFAULT_REQUESTED_HEADROOM = 2f

    fun inspect(activity: Activity): HdrDisplayDiagnostics {
        val display = requireNotNull(activity.display) { "Activity is not attached to a display" }
        val mode = display.mode
        val candidates =
            display.supportedModes.map {
                DisplayModeCandidate(
                    id = it.modeId,
                    width = it.physicalWidth,
                    height = it.physicalHeight,
                    refreshRateHz = it.refreshRate,
                )
            }
        val maximumRate =
            DisplayRefreshPolicy.maximumRateForCurrentResolution(
                currentWidth = mode.physicalWidth,
                currentHeight = mode.physicalHeight,
                modes = candidates,
            )
        val hdrCapabilities = display.hdrCapabilities
        @Suppress("DEPRECATION")
        val supportedHdrTypes =
            if (Build.VERSION.SDK_INT >= 34) {
                mode.supportedHdrTypes
            } else {
                hdrCapabilities.supportedHdrTypes
            }
        val powerManager = activity.getSystemService(PowerManager::class.java)

        return HdrDisplayDiagnostics(
            sdkInt = Build.VERSION.SDK_INT,
            displayName = display.name,
            displayReportsHdr = display.isHdr,
            wideColorGamut = display.isWideColorGamut,
            hdrTypes = supportedHdrTypes.map(::hdrTypeName),
            maxLuminanceNits = hdrCapabilities.desiredMaxLuminance,
            maxAverageLuminanceNits = hdrCapabilities.desiredMaxAverageLuminance,
            minLuminanceNits = hdrCapabilities.desiredMinLuminance,
            hdrSdrRatioAvailable = Build.VERSION.SDK_INT >= 34 && display.isHdrSdrRatioAvailable,
            hdrSdrRatio =
                if (Build.VERSION.SDK_INT >= 34 && display.isHdrSdrRatioAvailable) {
                    display.hdrSdrRatio
                } else {
                    1f
                },
            currentRefreshRateHz = mode.refreshRate,
            maximumRefreshRateHz = maximumRate,
            supportedRefreshRatesHz =
                candidates
                    .map { it.refreshRateHz }
                    .distinctBy { (it * 100f).toInt() }
                    .sortedDescending(),
            powerSaveMode = powerManager.isPowerSaveMode,
            thermalStatus =
                if (Build.VERSION.SDK_INT >= 29) powerManager.currentThermalStatus else null,
        )
    }

    fun applyWindowContract(
        activity: Activity,
        request: HdrWindowRequest = HdrWindowRequest(),
    ): AppliedHdrWindowContract {
        val diagnostics = inspect(activity)
        val decision = HdrWindowPolicy.decide(Build.VERSION.SDK_INT, diagnostics.displayReportsHdr)
        val window = activity.window

        if (decision.shouldRequestHdrWindow) {
            window.colorMode = ActivityInfo.COLOR_MODE_HDR
        }
        if (decision.shouldRequestHeadroom) {
            window.setDesiredHdrHeadroom(request.desiredHeadroom)
        }

        // preferredRefreshRate is a scheduler hint, not a forced mode. Android can still
        // override it for Battery Saver, thermal state, another surface, or user policy.
        if (request.preferMaximumRefreshRate) {
            diagnostics.maximumRefreshRateHz?.let { requestedRate ->
                val attributes = window.attributes
                if (abs(attributes.preferredRefreshRate - requestedRate) > 0.01f) {
                    attributes.preferredRefreshRate = requestedRate
                    window.attributes = attributes
                }
            }
        }

        return AppliedHdrWindowContract(
            hdrWindowRequested = decision.shouldRequestHdrWindow,
            desiredHeadroom =
                if (decision.shouldRequestHeadroom) request.desiredHeadroom else null,
            preferredRefreshRateHz =
                if (request.preferMaximumRefreshRate) diagnostics.maximumRefreshRateHz else null,
        )
    }

    @Deprecated("Use applyWindowContract with a typed HdrWindowRequest")
    fun applyProbeContract(
        activity: Activity,
        desiredHeadroom: Float = DEFAULT_REQUESTED_HEADROOM,
    ): AppliedHdrWindowContract =
        applyWindowContract(activity, HdrWindowRequest(desiredHeadroom = desiredHeadroom))

    private fun hdrTypeName(type: Int): String =
        when (type) {
            Display.HdrCapabilities.HDR_TYPE_DOLBY_VISION -> "DOLBY_VISION"
            Display.HdrCapabilities.HDR_TYPE_HDR10 -> "HDR10"
            Display.HdrCapabilities.HDR_TYPE_HLG -> "HLG"
            Display.HdrCapabilities.HDR_TYPE_HDR10_PLUS -> "HDR10_PLUS"
            else -> "UNKNOWN($type)"
        }
}
