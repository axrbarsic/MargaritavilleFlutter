package com.alex.margaritaville.flutter.beta.hdr.runtime

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class VipHdrEffectsTest {
    @Test
    fun `pulse heat follows donor rise peak and two second cooling tail`() {
        assertEquals(0f, VipHdrPulseTiming.heat(0.0), 0.000_001f)
        assertTrue(VipHdrPulseTiming.heat(0.21) in 0f..1f)
        assertEquals(1f, VipHdrPulseTiming.heat(0.42), 0.000_001f)
        assertEquals(1f, VipHdrPulseTiming.heat(0.58), 0.000_001f)
        assertTrue(VipHdrPulseTiming.heat(1.58) in 0f..1f)
        assertEquals(0f, VipHdrPulseTiming.heat(2.58), 0.000_001f)
    }

    @Test
    fun `shared jelly transform is deterministic and time varying`() {
        val first = VipHdrJellyGeometry.transform(12.5, 0.75f, 0.42f, 2.625f)
        val repeated = VipHdrJellyGeometry.transform(12.5, 0.75f, 0.42f, 2.625f)
        val later = VipHdrJellyGeometry.transform(12.7, 0.75f, 0.42f, 2.625f)

        assertEquals(first, repeated)
        assertNotEquals(first, later)
        assertTrue(first.scaleX in 0.988f..1.012f)
        assertTrue(first.scaleY in 0.982f..1.018f)
    }
}
