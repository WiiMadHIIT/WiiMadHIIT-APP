//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import app_settings
import audio_session
import path_provider_foundation
import shared_preferences_foundation
import video_player_avfoundation

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  AppSettingsPlugin.register(with: registry.registrar(forPlugin: "AppSettingsPlugin"))
  AudioSessionPlugin.register(with: registry.registrar(forPlugin: "AudioSessionPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  FVPVideoPlayerPlugin.register(with: registry.registrar(forPlugin: "FVPVideoPlayerPlugin"))
}
