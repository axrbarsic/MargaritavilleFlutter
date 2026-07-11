package com.alex.margaritaville.flutter.beta.edr

import org.junit.Assert.assertEquals
import org.junit.Test

class AndroidEdrSceneGeometryTest {
    @Test
    fun `logical global coordinates become physical content-root pixels`() {
        val transform = AndroidRootPixelTransform(density = 2.5f, rootScreenXPx = 10, rootScreenYPx = 50)
        val geometry = geometry()

        val viewport = transform.viewport(geometry)
        val tile = transform.tile(geometry, 8.0, 40.0, 30.0, 98.0)

        assertEquals(15f, viewport.left, 0.001f)
        assertEquals(0f, viewport.top, 0.001f)
        assertEquals(265f, viewport.right, 0.001f)
        assertEquals(500f, viewport.bottom, 0.001f)
        assertEquals(35f, tile.left, 0.001f)
        assertEquals(75f, tile.top, 0.001f)
        assertEquals(110f, tile.right, 0.001f)
        assertEquals(320f, tile.bottom, 0.001f)
    }

    @Test
    fun `scroll offset only translates tile content not viewport`() {
        val transform = AndroidRootPixelTransform(2f, 0, 0)
        val base = geometry().copy(viewportLeft = 0.0, viewportTop = 0.0)
        val scrolled = base.copy(scrollOffsetX = 5.0, scrollOffsetY = 12.0)

        assertEquals(transform.viewport(base), transform.viewport(scrolled))
        assertEquals(-10f, transform.tile(scrolled, 0.0, 0.0, 10.0, 10.0).left, 0.001f)
        assertEquals(-24f, transform.tile(scrolled, 0.0, 0.0, 10.0, 10.0).top, 0.001f)
    }

    private fun geometry() =
        AndroidEdrGeometry(
            surfaceSessionId = 1,
            activationId = 1,
            layoutGeneration = 1,
            revision = 1,
            viewportLeft = 10.0,
            viewportTop = 20.0,
            viewportWidth = 100.0,
            viewportHeight = 200.0,
            scrollOffsetX = 0.0,
            scrollOffsetY = 10.0,
        )
}
