package com.alex.margaritaville.flutter.beta.edr

import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class AndroidEdrLifecycleGateTest {
    @Test
    fun `deferred callback is rejected after close`() {
        val gate = AndroidEdrLifecycleGate()
        val callbackEpoch = gate.capture()!!

        assertTrue(gate.accepts(callbackEpoch))
        assertTrue(gate.close())
        assertFalse(gate.accepts(callbackEpoch))
        assertNull(gate.capture())
    }

    @Test
    fun `close is idempotent`() {
        val gate = AndroidEdrLifecycleGate()

        assertTrue(gate.close())
        assertFalse(gate.close())
    }
}
