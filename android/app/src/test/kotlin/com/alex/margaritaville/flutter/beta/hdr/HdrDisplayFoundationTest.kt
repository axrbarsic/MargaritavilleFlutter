package com.alex.margaritaville.flutter.beta.hdr

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class HdrDisplayFoundationTest {
    @Test
    fun `refresh policy picks maximum finite rate at current resolution`() {
        val modes =
            listOf(
                DisplayModeCandidate(1, 1080, 2400, 60f),
                DisplayModeCandidate(2, 1080, 2400, 120.00001f),
                DisplayModeCandidate(3, 1440, 3120, 144f),
                DisplayModeCandidate(4, 1080, 2400, Float.NaN),
            )

        assertEquals(
            120.00001f,
            DisplayRefreshPolicy.maximumRateForCurrentResolution(1080, 2400, modes)!!,
            0.0001f,
        )
    }

    @Test
    fun `refresh policy returns null without compatible modes`() {
        assertNull(
            DisplayRefreshPolicy.maximumRateForCurrentResolution(
                1080,
                2400,
                listOf(DisplayModeCandidate(1, 1440, 3120, 120f)),
            ),
        )
    }

    @Test
    fun `UI toolkit HDR stays disabled before API 34`() {
        val decision = HdrWindowPolicy.decide(sdkInt = 33, displayReportsHdr = true)

        assertFalse(decision.shouldRequestHdrWindow)
        assertFalse(decision.shouldRequestHeadroom)
    }

    @Test
    fun `API 34 requests HDR window but not explicit headroom`() {
        val decision = HdrWindowPolicy.decide(sdkInt = 34, displayReportsHdr = true)

        assertTrue(decision.shouldRequestHdrWindow)
        assertFalse(decision.shouldRequestHeadroom)
    }

    @Test
    fun `API 35 HDR display requests window and headroom`() {
        val decision = HdrWindowPolicy.decide(sdkInt = 35, displayReportsHdr = true)

        assertTrue(decision.shouldRequestHdrWindow)
        assertTrue(decision.shouldRequestHeadroom)
    }

    @Test
    fun `non-HDR display never requests HDR contract`() {
        val decision = HdrWindowPolicy.decide(sdkInt = 36, displayReportsHdr = false)

        assertFalse(decision.shouldRequestHdrWindow)
        assertFalse(decision.shouldRequestHeadroom)
    }
}
