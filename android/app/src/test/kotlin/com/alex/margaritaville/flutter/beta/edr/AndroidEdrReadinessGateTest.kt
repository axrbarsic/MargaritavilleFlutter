package com.alex.margaritaville.flutter.beta.edr

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class AndroidEdrReadinessGateTest {
    @Test
    fun `stale first draw cannot acknowledge current content`() {
        val gate = AndroidEdrReadinessGate()
        gate.await(lease(content = 2), beganActivation = true)

        assertNull(gate.consumeFirstDraw(contentRevision = 1) { true })
        assertEquals(lease(content = 2), gate.consumeFirstDraw(contentRevision = 2) { true })
    }

    @Test
    fun `inactive lease cannot acknowledge even matching content`() {
        val gate = AndroidEdrReadinessGate()
        gate.await(lease(content = 3), beganActivation = true)

        assertNull(gate.consumeFirstDraw(contentRevision = 3) { false })
        assertEquals(lease(content = 3), gate.consumeFirstDraw(contentRevision = 3) { true })
    }

    @Test
    fun `duplicate configuration is acknowledged once`() {
        val gate = AndroidEdrReadinessGate()
        val lease = lease(content = 4)
        gate.await(lease, beganActivation = true)
        assertEquals(lease, gate.consumeFirstDraw(4) { true })

        gate.await(lease, beganActivation = false)
        assertNull(gate.consumeFirstDraw(4) { true })
    }

    @Test
    fun `new activation can reuse content revision`() {
        val gate = AndroidEdrReadinessGate()
        val first = lease(activation = 1, content = 1)
        val second = lease(activation = 2, content = 1)
        gate.await(first, beganActivation = true)
        gate.consumeFirstDraw(1) { true }

        gate.await(second, beganActivation = true)

        assertEquals(second, gate.consumeFirstDraw(1) { true })
    }

    private fun lease(
        activation: Long = 1,
        content: Long,
    ) = AndroidEdrReadinessLease(1, activation, content)
}
