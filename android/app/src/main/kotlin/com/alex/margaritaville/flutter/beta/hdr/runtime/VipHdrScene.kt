package com.alex.margaritaville.flutter.beta.hdr.runtime

import kotlin.math.max
import kotlin.math.min

data class VipHdrPointPx(
    val x: Float,
    val y: Float,
) {
    init {
        require(x.isFinite() && y.isFinite()) { "Point coordinates must be finite" }
    }
}

data class VipHdrRectPx(
    val left: Float,
    val top: Float,
    val right: Float,
    val bottom: Float,
) {
    init {
        require(listOf(left, top, right, bottom).all(Float::isFinite)) {
            "Rectangle coordinates must be finite"
        }
        require(right > left && bottom > top) { "Rectangle must have positive area" }
    }

    fun intersects(other: VipHdrRectPx): Boolean =
        max(left, other.left) < min(right, other.right) &&
            max(top, other.top) < min(bottom, other.bottom)
}

sealed interface VipHdrShapePx {
    val bounds: VipHdrRectPx

    data class RoundedRect(
        override val bounds: VipHdrRectPx,
        val cornerRadiusPx: Float,
    ) : VipHdrShapePx {
        init {
            require(cornerRadiusPx.isFinite() && cornerRadiusPx >= 0f) {
                "Corner radius must be finite and non-negative"
            }
        }
    }

    data class Polygon(
        val points: List<VipHdrPointPx>,
    ) : VipHdrShapePx {
        init {
            require(points.size >= 3) { "Polygon requires at least three points" }
        }

        override val bounds: VipHdrRectPx =
            VipHdrRectPx(
                left = points.minOf(VipHdrPointPx::x),
                top = points.minOf(VipHdrPointPx::y),
                right = points.maxOf(VipHdrPointPx::x),
                bottom = points.maxOf(VipHdrPointPx::y),
            )
    }
}

data class VipHdrPulse(
    val periodMillis: Long,
    val minimumOpacity: Float,
    val phaseOffset: Float = 0f,
    val startedAtNanos: Long? = null,
    val colorArgb: Int? = null,
    val boostColorArgb: Int? = null,
    val springIntensity: Float = 0f,
) {
    init {
        require(periodMillis > 0) { "Pulse period must be positive" }
        require(minimumOpacity.isFinite() && minimumOpacity in 0f..1f) {
            "Pulse opacity must be within [0, 1]"
        }
        require(phaseOffset.isFinite()) { "Pulse phase must be finite" }
        require(startedAtNanos == null || startedAtNanos >= 0L) {
            "Pulse start must use a non-negative monotonic timestamp"
        }
        require(springIntensity.isFinite() && springIntensity >= 0f) {
            "Spring intensity must be finite and non-negative"
        }
    }

    val usesDonorTimeline: Boolean
        get() = startedAtNanos != null && colorArgb != null && boostColorArgb != null
}

data class VipHdrJelly(
    val speed: Float,
    val seed: Float,
) {
    init {
        require(speed.isFinite() && speed > 0f) { "Jelly speed must be finite and positive" }
        require(seed.isFinite()) { "Jelly seed must be finite" }
    }
}

data class VipHdrCellVisual(
    val id: String,
    val shape: VipHdrShapePx,
    val baseColorArgb: Int,
    val primaryText: String? = null,
    val secondaryText: String? = null,
    val primaryFontSizeSp: Float = 44f,
    val secondaryFontSizeSp: Float = 16f,
    val desiredHeadroom: Float = 2f,
    val opacity: Float = 1f,
    val pulse: VipHdrPulse? = null,
    val jelly: VipHdrJelly? = null,
) {
    init {
        require(id.isNotBlank()) { "Cell id must not be blank" }
        require(desiredHeadroom.isFinite() && desiredHeadroom in 1f..10_000f) {
            "Desired headroom must be within [1, 10000]"
        }
        require(opacity.isFinite() && opacity in 0f..1f) { "Opacity must be within [0, 1]" }
        require(primaryFontSizeSp.isFinite() && primaryFontSizeSp > 0f) {
            "Primary font size must be finite and positive"
        }
        require(secondaryFontSizeSp.isFinite() && secondaryFontSizeSp > 0f) {
            "Secondary font size must be finite and positive"
        }
    }
}

data class VipHdrScene(
    val revision: Long,
    val viewportPx: VipHdrRectPx,
    val cells: List<VipHdrCellVisual>,
    val contentRevision: Long? = null,
    val presentationRevision: Long? = null,
) {
    init {
        require(cells.map(VipHdrCellVisual::id).distinct().size == cells.size) {
            "Cell ids must be unique within a scene"
        }
    }

    val visibleCells: List<VipHdrCellVisual>
        get() = cells.filter { it.shape.bounds.intersects(viewportPx) && it.opacity > 0f }

    val hasVisibleAnimation: Boolean
        get() = visibleCells.any { it.pulse != null || it.jelly != null }
}
