package com.alex.margaritaville.flutter.beta.hdr.runtime

import kotlin.math.max
import kotlin.math.pow

object VipHdrPulseTiming {
    const val RISE_SECONDS = 0.42
    const val PEAK_SECONDS = 0.58
    const val FADE_SECONDS = 2.0
    const val TOTAL_SECONDS = PEAK_SECONDS + FADE_SECONDS
    const val RUBBER_AMPLITUDE_MULTIPLIER = 1.7f
    const val SCALE_COEFFICIENT = 0.09f
    const val VERTICAL_OFFSET_DP = 7f

    fun heat(elapsedSeconds: Double): Float {
        if (elapsedSeconds <= 0.0) return 0f
        if (elapsedSeconds < RISE_SECONDS) {
            return smootherStep(elapsedSeconds / RISE_SECONDS).toFloat()
        }
        if (elapsedSeconds <= PEAK_SECONDS) return 1f
        if (elapsedSeconds >= TOTAL_SECONDS) return 0f
        val coolingProgress = (elapsedSeconds - PEAK_SECONDS) / FADE_SECONDS
        val remaining = 1.0 - smootherStep(coolingProgress)
        return max(remaining, 0.0).pow(0.7).toFloat()
    }

    private fun smootherStep(rawValue: Double): Double {
        val value = rawValue.coerceIn(0.0, 1.0)
        return value * value * value * (value * (value * 6.0 - 15.0) + 10.0)
    }
}
