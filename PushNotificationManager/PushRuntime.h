//
//  PushRuntime.h
//  Pushwoosh SDK
//  (c) Pushwoosh 2012
//

#import <Foundation/Foundation.h>

@interface NSApplication(SupressWarnings)
- (void)application:(NSApplication *)application pw_didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken;
- (void)application:(NSApplication *)application pw_didFailToRegisterForRemoteNotificationsWithError:(NSError *)err;
- (void)application:(NSApplication *)application pw_didReceiveRemoteNotification:(NSDictionary *)userInfo;

- (void)pw_applicationDidFinishLaunching:(NSNotification *)aNotification;
@end