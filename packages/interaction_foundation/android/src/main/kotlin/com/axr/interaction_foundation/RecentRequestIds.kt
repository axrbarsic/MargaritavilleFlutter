package com.axr.interaction_foundation

internal class RecentRequestIds(
  private val capacity: Int = 256,
) {
  private val ids = linkedSetOf<String>()

  init {
    require(capacity > 0)
  }

  fun remember(id: String): Boolean {
    if (!ids.add(id)) return false
    if (ids.size > capacity) ids.remove(ids.first())
    return true
  }
}
