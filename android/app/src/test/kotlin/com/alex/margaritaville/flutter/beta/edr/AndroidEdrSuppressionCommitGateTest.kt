package com.alex.margaritaville.flutter.beta.edr

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class AndroidEdrSuppressionCommitGateTest {
    @Test
    fun `exact compositor commit completes only its pending presentation`() {
        val gate = AndroidEdrSuppressionCommitGate()
        val commit = gate.begin(7, 11, 5)

        assertTrue(gate.complete(commit))
        assertFalse(gate.complete(commit))
    }

    @Test
    fun `late compositor commit cannot confirm a replaced presentation`() {
        val gate = AndroidEdrSuppressionCommitGate()
        val stale = gate.begin(7, 11, 5)
        val current = gate.begin(7, 11, 6)

        assertFalse(gate.complete(stale))
        assertTrue(gate.complete(current))
    }

    @Test
    fun `invalidated commit cannot acknowledge after clear or close`() {
        val gate = AndroidEdrSuppressionCommitGate()
        val commit = gate.begin(7, 11, 5)
        gate.invalidate()

        assertFalse(gate.complete(commit))
    }

    @Test
    fun `detach cancellation completes current gate without a false frame receipt`() {
        val gate = AndroidEdrSuppressionCommitGate()
        val commit = gate.begin(7, 11, 5)

        assertTrue(gate.cancel(commit))
        assertFalse(gate.complete(commit))
        assertFalse(gate.cancel(commit))
    }

    @Test
    fun `stale cancellation cannot consume the current presentation`() {
        val gate = AndroidEdrSuppressionCommitGate()
        val stale = gate.begin(7, 11, 5)
        val current = gate.begin(7, 11, 6)

        assertFalse(gate.cancel(stale))
        assertTrue(gate.complete(current))
    }
}
