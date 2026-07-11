package com.alex.margaritaville.flutter.beta.hdr.runtime

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class VipHdrLabelLayoutTest {
    @Test
    fun `compact Android tile scales both labels exactly once`() {
        val metrics = VipHdrLabelLayout.resolve(72.4f)
        val expectedScale = 72.4f / 98f

        assertEquals(expectedScale, metrics.contentScale, 0.0001f)
        assertEquals(44f * expectedScale, metrics.primaryFontSizeSp, 0.0001f)
        assertEquals(16f * expectedScale, metrics.secondaryFontSizeSp, 0.0001f)
        assertEquals(10f * expectedScale, metrics.verticalPaddingDp, 0.0001f)
        assertEquals(6f * expectedScale, metrics.gapDp, 0.0001f)

        val primaryBudget =
            72.4f -
                metrics.verticalPaddingDp * 2f -
                metrics.gapDp -
                metrics.secondaryFontSizeSp
        assertTrue(primaryBudget > metrics.primaryFontSizeSp)
    }
}
