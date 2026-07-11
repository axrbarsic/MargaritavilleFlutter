package com.alex.margaritaville.flutter.beta.hdr.runtime

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Test

class VipHdrRuntimeTest {
    @Test
    fun `animated visible scene uses one shared clock subscription`() {
        val clock = FakeFrameClock()
        val surface = FakeSurface()
        val runtime = createRuntime(clock = clock)

        activate(runtime, surface)
        runtime.updateScene(scene(animated = true))
        runtime.updateScene(scene(animated = true, revision = 2))

        assertEquals(VipHdrRuntimeStatus.ACTIVE_ANIMATED, runtime.snapshot.status)
        assertEquals(1, clock.listeners.size)
        assertTrue(runtime.snapshot.clockSubscribed)

        clock.dispatch(123L)
        assertEquals(123L, surface.packets.last().frameTimeNanos)
    }

    @Test
    fun `static scene renders without keeping the clock alive`() {
        val clock = FakeFrameClock()
        val surface = FakeSurface()
        val runtime = createRuntime(clock = clock)

        activate(runtime, surface)
        runtime.updateScene(scene(animated = false))

        assertEquals(VipHdrRuntimeStatus.ACTIVE_STATIC, runtime.snapshot.status)
        assertTrue(surface.packets.isNotEmpty())
        assertTrue(clock.listeners.isEmpty())
    }

    @Test
    fun `offscreen cells pause frames and clear the surface`() {
        val clock = FakeFrameClock()
        val surface = FakeSurface()
        val runtime = createRuntime(clock = clock)

        activate(runtime, surface)
        runtime.updateScene(scene(animated = true))
        runtime.updateScene(offscreenScene())

        assertEquals(VipHdrRuntimeStatus.IDLE, runtime.snapshot.status)
        assertTrue(clock.listeners.isEmpty())
        assertTrue(surface.clearCount > 0)
    }

    @Test
    fun `host pause unsubscribes and prevents later frame presentation`() {
        val clock = FakeFrameClock()
        val surface = FakeSurface()
        val runtime = createRuntime(clock = clock)

        activate(runtime, surface)
        runtime.updateScene(scene(animated = true))
        val packetCount = surface.packets.size
        runtime.setHostResumed(false)
        clock.dispatch(456L)

        assertEquals(VipHdrRuntimeStatus.PAUSED, runtime.snapshot.status)
        assertTrue(clock.listeners.isEmpty())
        assertEquals(packetCount, surface.packets.size)
    }

    @Test
    fun `feature visibility pauses all work`() {
        val clock = FakeFrameClock()
        val surface = FakeSurface()
        val runtime = createRuntime(clock = clock)

        activate(runtime, surface)
        runtime.updateScene(scene(animated = true))
        runtime.setViewportVisible(false)

        assertEquals(VipHdrRuntimeStatus.OFFSCREEN, runtime.snapshot.status)
        assertFalse(runtime.snapshot.clockSubscribed)
    }

    @Test
    fun `power or thermal degradation keeps a static HDR frame without animation`() {
        val clock = FakeFrameClock()
        val surface = FakeSurface()
        val runtime = createRuntime(clock = clock, animationAllowed = false)

        activate(runtime, surface)
        runtime.updateScene(scene(animated = true))

        assertEquals(VipHdrRuntimeStatus.ACTIVE_STATIC, runtime.snapshot.status)
        assertTrue(clock.listeners.isEmpty())
        assertTrue(surface.packets.isNotEmpty())
    }

    @Test
    fun `unsupported display never renders`() {
        val clock = FakeFrameClock()
        val surface = FakeSurface()
        val runtime = createRuntime(clock = clock, hdrSupported = false)

        activate(runtime, surface)
        runtime.updateScene(scene(animated = true))

        assertEquals(VipHdrRuntimeStatus.UNSUPPORTED, runtime.snapshot.status)
        assertTrue(surface.packets.isEmpty())
        assertTrue(clock.listeners.isEmpty())
    }

    @Test
    fun `runtime rejects a second render surface`() {
        val runtime = createRuntime()
        runtime.attachSurface(FakeSurface())

        assertThrows(IllegalStateException::class.java) {
            runtime.attachSurface(FakeSurface())
        }
    }

    @Test
    fun `close clears surface and rejects future mutations`() {
        val surface = FakeSurface()
        val runtime = createRuntime()
        runtime.attachSurface(surface)
        runtime.close()

        assertEquals(VipHdrRuntimeStatus.CLOSED, runtime.snapshot.status)
        assertTrue(surface.clearCount > 0)
        assertThrows(IllegalStateException::class.java) {
            runtime.updateScene(scene(animated = false))
        }
    }

    private fun createRuntime(
        clock: FakeFrameClock = FakeFrameClock(),
        hdrSupported: Boolean = true,
        animationAllowed: Boolean = true,
    ): VipHdrRuntime =
        VipHdrRuntime(
            frameClock = clock,
            capabilities =
                VipHdrRuntimeCapabilities(
                    hdrUiToolkitSupported = hdrSupported,
                    animationAllowed = animationAllowed,
                    requestedHeadroom = 2f,
                ),
        )

    private fun activate(
        runtime: VipHdrRuntime,
        surface: FakeSurface,
    ) {
        runtime.attachSurface(surface)
        runtime.setSurfaceAvailable(true)
        runtime.setHostResumed(true)
    }

    private fun scene(
        animated: Boolean,
        revision: Long = 1,
    ): VipHdrScene =
        VipHdrScene(
            revision = revision,
            viewportPx = VipHdrRectPx(0f, 0f, 100f, 100f),
            cells =
                listOf(
                    VipHdrCellVisual(
                        id = "101",
                        shape = VipHdrShapePx.RoundedRect(VipHdrRectPx(10f, 10f, 50f, 50f), 4f),
                        baseColorArgb = 0xFF00FF00.toInt(),
                        pulse = if (animated) VipHdrPulse(1_000, 0.5f) else null,
                    ),
                ),
        )

    private fun offscreenScene(): VipHdrScene =
        VipHdrScene(
            revision = 3,
            viewportPx = VipHdrRectPx(0f, 0f, 100f, 100f),
            cells =
                listOf(
                    VipHdrCellVisual(
                        id = "outside",
                        shape = VipHdrShapePx.RoundedRect(VipHdrRectPx(200f, 200f, 250f, 250f), 4f),
                        baseColorArgb = 0xFFFFFFFF.toInt(),
                        pulse = VipHdrPulse(1_000, 0.5f),
                    ),
                ),
        )
}

private class FakeFrameClock : VipHdrFrameClock {
    val listeners = linkedSetOf<VipHdrFrameListener>()

    override fun addListener(listener: VipHdrFrameListener) {
        listeners += listener
    }

    override fun removeListener(listener: VipHdrFrameListener) {
        listeners -= listener
    }

    fun dispatch(frameTimeNanos: Long) {
        listeners.toList().forEach { it.onFrame(frameTimeNanos) }
    }
}

private class FakeSurface : VipHdrRenderSurface {
    val packets = mutableListOf<VipHdrRenderPacket>()
    var clearCount = 0

    override fun present(packet: VipHdrRenderPacket) {
        packets += packet
    }

    override fun clear() {
        clearCount += 1
    }
}
