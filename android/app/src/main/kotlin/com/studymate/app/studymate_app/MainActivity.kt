package com.studymate.app.studymate_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.RenderMode

// Force TextureView rendering instead of SurfaceView.
// SurfaceView causes "Width is zero" black screen on API 37 emulators.
class MainActivity : FlutterActivity() {
    override fun getRenderMode(): RenderMode = RenderMode.texture
}
