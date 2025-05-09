//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<permission_handler_apple/PermissionHandlerPlugin.h>)
#import <permission_handler_apple/PermissionHandlerPlugin.h>
#else
@import permission_handler_apple;
#endif

#if __has_include(<simple_barcode_scanner/SwiftFlutterBarcodeScannerPlugin.h>)
#import <simple_barcode_scanner/SwiftFlutterBarcodeScannerPlugin.h>
#else
@import simple_barcode_scanner;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [PermissionHandlerPlugin registerWithRegistrar:[registry registrarForPlugin:@"PermissionHandlerPlugin"]];
  [SwiftFlutterBarcodeScannerPlugin registerWithRegistrar:[registry registrarForPlugin:@"SwiftFlutterBarcodeScannerPlugin"]];
}

@end
