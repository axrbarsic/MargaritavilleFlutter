package com.alex.margaritaville.flutter.beta.hdr.runtime

import android.graphics.Path
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sin

data class VipHdrJellyTransform(
    val scaleX: Float,
    val scaleY: Float,
    val offsetXPx: Float,
    val offsetYPx: Float,
)

object VipHdrJellyGeometry {
    fun transform(
        timeSeconds: Double,
        speed: Float,
        seed: Float,
        density: Float,
    ): VipHdrJellyTransform {
        val normalizedSpeed = speed.coerceIn(0.2f, 2.5f).toDouble()
        val phase = timeSeconds * normalizedSpeed + seed * 11.0
        return VipHdrJellyTransform(
            scaleX = (1.0 + 0.012 * sin(phase * 1.7)).toFloat(),
            scaleY = (1.0 + 0.018 * cos(phase * 1.4)).toFloat(),
            offsetXPx = (1.2 * density * sin(phase * 1.1)).toFloat(),
            offsetYPx = (0.8 * density * cos(phase * 1.3)).toFloat(),
        )
    }

    fun path(
        bounds: VipHdrRectPx,
        timeSeconds: Double,
        speed: Float,
        seed: Float,
        cornerRadiusPx: Float,
        density: Float,
    ): Path {
        val normalizedSpeed = speed.coerceIn(0.2f, 2.5f).toDouble()
        val phase = timeSeconds * normalizedSpeed
        val amplitude = min((bounds.bottom - bounds.top) * 0.22f, 18f * density)
        val radius =
            min(
                cornerRadiusPx,
                min((bounds.bottom - bounds.top) * 0.46f, (bounds.right - bounds.left) * 0.12f),
            )
        val path = Path()
        path.moveTo(
            bounds.left + radius,
            bounds.top + offset(0, 0.0, phase, amplitude, seed.toDouble()),
        )
        addHorizontalEdge(path, bounds.top, bounds.left + radius, bounds.right - radius, 0, phase, amplitude, seed)
        path.quadTo(
            bounds.right + offset(4, 0.25, phase, amplitude * 0.55f, seed.toDouble()),
            bounds.top,
            bounds.right,
            bounds.top + radius,
        )
        addVerticalEdge(path, bounds.right, bounds.top + radius, bounds.bottom - radius, 1, phase, amplitude, seed)
        path.quadTo(
            bounds.right,
            bounds.bottom + offset(5, 0.75, phase, amplitude * 0.55f, seed.toDouble()),
            bounds.right - radius,
            bounds.bottom,
        )
        addHorizontalEdge(path, bounds.bottom, bounds.right - radius, bounds.left + radius, 2, phase, amplitude, seed)
        path.quadTo(
            bounds.left + offset(6, 0.35, phase, amplitude * 0.55f, seed.toDouble()),
            bounds.bottom,
            bounds.left,
            bounds.bottom - radius,
        )
        addVerticalEdge(path, bounds.left, bounds.bottom - radius, bounds.top + radius, 3, phase, amplitude, seed)
        path.quadTo(
            bounds.left,
            bounds.top + offset(7, 0.9, phase, amplitude * 0.55f, seed.toDouble()),
            bounds.left + radius,
            bounds.top,
        )
        path.close()
        return path
    }

    private fun addHorizontalEdge(
        path: Path,
        y: Float,
        fromX: Float,
        toX: Float,
        edge: Int,
        time: Double,
        amplitude: Float,
        seed: Float,
    ) {
        val points = FloatArray((HORIZONTAL_SEGMENTS + 1) * 2)
        for (index in 0..HORIZONTAL_SEGMENTS) {
            val unit = index.toDouble() / HORIZONTAL_SEGMENTS
            points[index * 2] = fromX + (toX - fromX) * unit.toFloat()
            points[index * 2 + 1] = y + offset(edge, unit, time, amplitude, seed.toDouble())
        }
        addSmoothEdge(path, points)
    }

    private fun addVerticalEdge(
        path: Path,
        x: Float,
        fromY: Float,
        toY: Float,
        edge: Int,
        time: Double,
        amplitude: Float,
        seed: Float,
    ) {
        val points = FloatArray((VERTICAL_SEGMENTS + 1) * 2)
        for (index in 0..VERTICAL_SEGMENTS) {
            val unit = index.toDouble() / VERTICAL_SEGMENTS
            points[index * 2] = x + offset(edge, unit, time, amplitude * 0.55f, seed.toDouble())
            points[index * 2 + 1] = fromY + (toY - fromY) * unit.toFloat()
        }
        addSmoothEdge(path, points)
    }

    private fun addSmoothEdge(
        path: Path,
        points: FloatArray,
    ) {
        val count = points.size / 2
        for (index in 0 until count - 1) {
            val previousIndex = max(index - 1, 0)
            val nextIndex = index + 1
            val afterNextIndex = min(index + 2, count - 1)
            val previousX = points[previousIndex * 2]
            val previousY = points[previousIndex * 2 + 1]
            val currentX = points[index * 2]
            val currentY = points[index * 2 + 1]
            val nextX = points[nextIndex * 2]
            val nextY = points[nextIndex * 2 + 1]
            val afterNextX = points[afterNextIndex * 2]
            val afterNextY = points[afterNextIndex * 2 + 1]
            path.cubicTo(
                currentX + (nextX - previousX) / 6f,
                currentY + (nextY - previousY) / 6f,
                nextX - (afterNextX - currentX) / 6f,
                nextY - (afterNextY - currentY) / 6f,
                nextX,
                nextY,
            )
        }
    }

    private fun offset(
        edge: Int,
        unit: Double,
        time: Double,
        amplitude: Float,
        seed: Double,
    ): Float {
        val edgeSeed = seed * 19.37 + edge * 0.731
        val slow = sin((unit * (1.7 + edgeSeed % 1.9) + time * (0.31 + edgeSeed * 0.017) + edgeSeed) * PI * 2)
        val medium = sin((unit * (3.1 + edgeSeed % 2.4) - time * (0.47 + seed * 0.09) + edgeSeed * 1.41) * PI * 2)
        val fast = sin((unit * (4.6 + seed * 1.7) + time * (0.61 + edge * 0.017) + edgeSeed * 2.17) * PI * 2)
        val drift = sin((time * 0.113 + seed * 8 + edge) * PI * 2)
        return ((slow * 0.52 + medium * 0.31 + fast * 0.11 + drift * 0.06) * amplitude).toFloat()
    }

    private const val HORIZONTAL_SEGMENTS = 28
    private const val VERTICAL_SEGMENTS = 12
}
