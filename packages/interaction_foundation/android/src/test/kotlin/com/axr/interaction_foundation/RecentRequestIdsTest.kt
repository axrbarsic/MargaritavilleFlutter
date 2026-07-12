package com.axr.interaction_foundation

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class RecentRequestIdsTest {
  @Test
  fun duplicateIsRejectedUntilBoundedEviction() {
    val ids = RecentRequestIds(capacity = 3)

    assertTrue(ids.remember("a"))
    assertFalse(ids.remember("a"))
    assertTrue(ids.remember("b"))
    assertTrue(ids.remember("c"))
    assertTrue(ids.remember("d"))
    assertTrue(ids.remember("a"))
  }
}
