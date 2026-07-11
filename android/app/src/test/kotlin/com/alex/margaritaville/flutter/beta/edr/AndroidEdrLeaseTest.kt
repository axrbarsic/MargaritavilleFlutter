package com.alex.margaritaville.flutter.beta.edr

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class AndroidEdrLeaseTest {
    @Test
    fun `higher activation supersedes previous session`() {
        val lease = AndroidEdrLease()
        assertTrue(lease.configure(configuration(1, 1), geometry(1, 1))!!.beganActivation)

        val next = lease.configure(configuration(2, 2), geometry(2, 2))

        assertTrue(next!!.beganActivation)
        assertEquals(2L, lease.activeSessionId)
        assertNull(lease.configure(configuration(1, 1, content = 2), geometry(1, 1)))
    }

    @Test
    fun `same activation only accepts its active session`() {
        val lease = AndroidEdrLease()
        lease.configure(configuration(1, 5), geometry(1, 5))

        assertNull(lease.configure(configuration(2, 5), geometry(2, 5)))
        assertFalse(
            lease.configure(configuration(1, 5, content = 2), geometry(1, 5, revision = 2))!!
                .beganActivation,
        )
    }

    @Test
    fun `stale content and layout are rejected`() {
        val lease = AndroidEdrLease()
        lease.configure(configuration(1, 1, layout = 2, content = 4), geometry(1, 1, layout = 2))

        assertNull(
            lease.configure(
                configuration(1, 1, layout = 2, content = 3),
                geometry(1, 1, layout = 2, revision = 2),
            ),
        )
        assertNull(
            lease.configure(
                configuration(1, 1, layout = 1, content = 5),
                geometry(1, 1, layout = 1, revision = 3),
            ),
        )
    }

    @Test
    fun `geometry-only update requires exact active lease and newer revision`() {
        val lease = AndroidEdrLease()
        lease.configure(configuration(1, 1), geometry(1, 1, revision = 4))

        assertNull(lease.updateGeometry(geometry(1, 1, revision = 3)))
        assertNull(lease.updateGeometry(geometry(2, 1, revision = 5)))
        assertEquals(5L, lease.updateGeometry(geometry(1, 1, revision = 5))!!.revision)
    }

    @Test
    fun `future layout geometry is retained and wins configure race`() {
        val lease = AndroidEdrLease()
        lease.configure(configuration(1, 1, layout = 1), geometry(1, 1, layout = 1))
        lease.updateGeometry(geometry(1, 1, layout = 2, revision = 9))

        val configured =
            lease.configure(
                configuration(1, 1, layout = 2, content = 2),
                geometry(1, 1, layout = 2, revision = 4),
            )

        assertEquals(9L, configured!!.geometry.revision)
        assertNull(lease.pendingGeometry)
    }

    @Test
    fun `future activation geometry waits for matching configure`() {
        val lease = AndroidEdrLease()
        lease.updateGeometry(geometry(session = 7, activation = 8, revision = 11))

        val configured =
            lease.configure(
                configuration(session = 7, activation = 8),
                geometry(session = 7, activation = 8, revision = 3),
            )

        assertEquals(11L, configured!!.geometry.revision)
    }

    @Test
    fun `stale clear cannot release current activation`() {
        val lease = AndroidEdrLease()
        lease.configure(configuration(1, 1, content = 5), geometry(1, 1))

        assertFalse(lease.clear(1, 1, 4))
        assertTrue(lease.isActive(1, 1, 5))
        assertTrue(lease.clear(1, 1, 5))
        assertNull(lease.activeSessionId)
    }

    @Test
    fun `invalid dimensions are rejected`() {
        val lease = AndroidEdrLease()
        val invalid = geometry(1, 1).copy(viewportWidth = 0.0)

        assertNull(lease.configure(configuration(1, 1), invalid))
        assertNull(lease.updateGeometry(invalid))
    }

    private fun configuration(
        session: Long,
        activation: Long,
        layout: Long = 1,
        content: Long = 1,
    ) = AndroidEdrConfiguration(session, activation, layout, content)

    private fun geometry(
        session: Long,
        activation: Long,
        layout: Long = 1,
        revision: Long = 1,
    ) =
        AndroidEdrGeometry(
            surfaceSessionId = session,
            activationId = activation,
            layoutGeneration = layout,
            revision = revision,
            viewportLeft = 0.0,
            viewportTop = 0.0,
            viewportWidth = 100.0,
            viewportHeight = 200.0,
            scrollOffsetX = 0.0,
            scrollOffsetY = 0.0,
        )
}
