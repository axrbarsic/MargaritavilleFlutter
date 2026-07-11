package com.axr.interaction_foundation

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.view.HapticFeedbackConstants
import android.view.View

internal class AndroidInteractionHapticPlayer(
  context: Context,
  private val viewProvider: () -> View?,
) {
  private val vibrator = context.getSystemService(Vibrator::class.java)

  fun perform(cue: NativeFeedbackCue) {
    if (cue == NativeFeedbackCue.NONE) return
    val constant = constantFor(cue)
    if (viewProvider()?.performHapticFeedback(constant) == true) return
    val (duration, amplitude) = fallbackFor(cue)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      vibrator?.vibrate(VibrationEffect.createOneShot(duration, amplitude))
    } else {
      @Suppress("DEPRECATION")
      vibrator?.vibrate(duration)
    }
  }

  private fun constantFor(cue: NativeFeedbackCue): Int = when (cue) {
    NativeFeedbackCue.TAP -> HapticFeedbackConstants.KEYBOARD_TAP
    NativeFeedbackCue.CONFIRM -> api30(
      HapticFeedbackConstants.CONFIRM,
      HapticFeedbackConstants.VIRTUAL_KEY,
    )
    NativeFeedbackCue.LONG_PRESS -> HapticFeedbackConstants.LONG_PRESS
    NativeFeedbackCue.HOLD_START -> api30(
      HapticFeedbackConstants.GESTURE_START,
      HapticFeedbackConstants.CLOCK_TICK,
    )
    NativeFeedbackCue.HOLD_WARNING -> api30(
      HapticFeedbackConstants.REJECT,
      HapticFeedbackConstants.LONG_PRESS,
    )
    NativeFeedbackCue.HOLD_COMMIT -> api30(
      HapticFeedbackConstants.GESTURE_END,
      HapticFeedbackConstants.LONG_PRESS,
    )
    NativeFeedbackCue.SELECT -> HapticFeedbackConstants.VIRTUAL_KEY
    NativeFeedbackCue.DESELECT -> HapticFeedbackConstants.KEYBOARD_TAP
    NativeFeedbackCue.INVALID -> api30(
      HapticFeedbackConstants.REJECT,
      HapticFeedbackConstants.LONG_PRESS,
    )
    NativeFeedbackCue.DETENT -> HapticFeedbackConstants.CLOCK_TICK
    NativeFeedbackCue.NONE -> HapticFeedbackConstants.KEYBOARD_TAP
  }

  private fun api30(value: Int, fallback: Int): Int =
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) value else fallback

  private fun fallbackFor(cue: NativeFeedbackCue): Pair<Long, Int> = when (cue) {
    NativeFeedbackCue.TAP -> 10L to 92
    NativeFeedbackCue.CONFIRM -> 22L to 230
    NativeFeedbackCue.LONG_PRESS -> 28L to 255
    NativeFeedbackCue.HOLD_START -> 8L to 64
    NativeFeedbackCue.HOLD_WARNING -> 20L to 242
    NativeFeedbackCue.HOLD_COMMIT -> 30L to 255
    NativeFeedbackCue.SELECT -> 16L to 210
    NativeFeedbackCue.DESELECT -> 10L to 82
    NativeFeedbackCue.INVALID -> 18L to 120
    NativeFeedbackCue.DETENT -> 10L to 158
    NativeFeedbackCue.NONE -> 1L to 1
  }
}
