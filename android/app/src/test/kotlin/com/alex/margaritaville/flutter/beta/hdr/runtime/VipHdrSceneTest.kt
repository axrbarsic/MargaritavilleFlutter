package com.alex.margaritaville.flutter.beta.hdr.runtime

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Test

class VipHdrSceneTest {
    @Test
    fun `scene only exposes cells intersecting the viewport`() {
        val scene =
            VipHdrScene(
                revision = 1,
                viewportPx = VipHdrRectPx(0f, 0f, 100f, 100f),
                cells =
                    listOf(
                        cell("visible", VipHdrRectPx(10f, 10f, 30f, 30f)),
                        cell("partial", VipHdrRectPx(90f, 90f, 110f, 110f)),
                        cell("outside", VipHdrRectPx(110f, 110f, 130f, 130f)),
                    ),
            )

        assertEquals(listOf("visible", "partial"), scene.visibleCells.map(VipHdrCellVisual::id))
    }

    @Test
    fun `only a visible pulse requires continuous frames`() {
        val static = cell("static", VipHdrRectPx(10f, 10f, 30f, 30f))
        val animatedOutside =
            cell("outside", VipHdrRectPx(110f, 110f, 130f, 130f), VipHdrPulse(1_000, 0.4f))
        val viewport = VipHdrRectPx(0f, 0f, 100f, 100f)

        assertFalse(VipHdrScene(1, viewport, listOf(static, animatedOutside)).hasVisibleAnimation)
        assertTrue(
            VipHdrScene(
                2,
                viewport,
                listOf(static.copy(pulse = VipHdrPulse(1_000, 0.4f))),
            ).hasVisibleAnimation,
        )
        assertTrue(
            VipHdrScene(
                3,
                viewport,
                listOf(static.copy(jelly = VipHdrJelly(speed = 0.75f, seed = 0.4f))),
            ).hasVisibleAnimation,
        )
    }

    @Test
    fun `duplicate ids are rejected`() {
        val viewport = VipHdrRectPx(0f, 0f, 100f, 100f)
        val duplicate = cell("101", VipHdrRectPx(10f, 10f, 30f, 30f))

        assertThrows(IllegalArgumentException::class.java) {
            VipHdrScene(1, viewport, listOf(duplicate, duplicate))
        }
    }

    @Test
    fun `invalid geometry and headroom are rejected at the boundary`() {
        assertThrows(IllegalArgumentException::class.java) {
            VipHdrRectPx(10f, 10f, 5f, 20f)
        }
        assertThrows(IllegalArgumentException::class.java) {
            VipHdrShapePx.Polygon(listOf(VipHdrPointPx(0f, 0f), VipHdrPointPx(1f, 1f)))
        }
        assertThrows(IllegalArgumentException::class.java) {
            cell("bad", VipHdrRectPx(0f, 0f, 10f, 10f)).copy(desiredHeadroom = 0.5f)
        }
    }

    private fun cell(
        id: String,
        bounds: VipHdrRectPx,
        pulse: VipHdrPulse? = null,
    ): VipHdrCellVisual =
        VipHdrCellVisual(
            id = id,
            shape = VipHdrShapePx.RoundedRect(bounds, 2f),
            baseColorArgb = 0xFFFFFFFF.toInt(),
            pulse = pulse,
        )
}
