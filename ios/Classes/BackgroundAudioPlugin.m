#import "BackgroundAudioPlugin.h"
#if __has_include(<background_audio/background_audio-Swift.h>)
#import <background_audio/background_audio-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "background_audio-Swift.h"
#endif

@implementation BackgroundAudioPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftBackgroundAudioPlugin registerWithRegistrar:registrar];
}
@end
