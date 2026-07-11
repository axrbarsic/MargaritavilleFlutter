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
    if (performMaximumPrimitive(cue)) return
    val (duration, amplitude) = fallbackFor(cue)
    val directPlayed = runCatching {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        vibrator?.vibrate(VibrationEffect.createOneShot(duration, amplitude))
      } else {
        @Suppress("DEPRECATION")
        vibrator?.vibrate(duration)
      }
      vibrator != null
    }.getOrDefault(false)
    if (!directPlayed) {
      viewProvider()?.performHapticFeedback(constantFor(cue))
    }
  }

  private fun performMaximumPrimitive(cue: NativeFeedbackCue): Boolean {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S || vibrator == null) return false
    val primitives = primitivesFor(cue)
    if (!vibrator.areAllPrimitivesSupported(*primitives.map { it.first }.toIntArray())) {
      return false
    }
    return runCatching {
      val composition = VibrationEffect.startComposition()
      primitives.forEach { (primitive, delayMs) ->
        composition.addPrimitive(primitive, 1f, delayMs)
      }
      vibrator.vibrate(composition.compose())
      true
    }.getOrDefault(false)
  }

  private fun primitivesFor(cue: NativeFeedbackCue): List<Pair<Int, Int>> = when (cue) {
    NativeFeedbackCue.TAP,
    NativeFeedbackCue.SELECT,
    -> listOf(VibrationEffect.Composition.PRIMITIVE_CLICK to 0)
    NativeFeedbackCue.CONFIRM -> listOf(
      VibrationEffect.Composition.PRIMITIVE_CLICK to 0,
      VibrationEffect.Composition.PRIMITIVE_THUD to 24,
    )
    NativeFeedbackCue.LONG_PRESS,
    NativeFeedbackCue.HOLD_COMMIT,
    -> listOf(
      VibrationEffect.Composition.PRIMITIVE_CLICK to 0,
      VibrationEffect.Composition.PRIMITIVE_THUD to 16,
    )
    NativeFeedbackCue.HOLD_START -> listOf(
      VibrationEffect.Composition.PRIMITIVE_CLICK to 0,
      VibrationEffect.Composition.PRIMITIVE_QUICK_RISE to 12,
    )
    NativeFeedbackCue.HOLD_WARNING,
    NativeFeedbackCue.INVALID,
    -> listOf(
      VibrationEffect.Composition.PRIMITIVE_QUICK_FALL to 0,
      VibrationEffect.Composition.PRIMITIVE_CLICK to 12,
    )
    NativeFeedbackCue.DESELECT,
    NativeFeedbackCue.DETENT,
    -> listOf(VibrationEffect.Composition.PRIMITIVE_TICK to 0)
    NativeFeedbackCue.NONE -> emptyList()
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
    NativeFeedbackCue.TAP -> 12L to 255
    NativeFeedbackCue.CONFIRM -> 32L to 255
    NativeFeedbackCue.LONG_PRESS -> 28L to 255
    NativeFeedbackCue.HOLD_START -> 18L to 255
    NativeFeedbackCue.HOLD_WARNING -> 28L to 255
    NativeFeedbackCue.HOLD_COMMIT -> 30L to 255
    NativeFeedbackCue.SELECT -> 18L to 255
    NativeFeedbackCue.DESELECT -> 12L to 255
    NativeFeedbackCue.INVALID -> 26L to 255
    NativeFeedbackCue.DETENT -> 10L to 255
    NativeFeedbackCue.NONE -> 1L to 1
  }
}
