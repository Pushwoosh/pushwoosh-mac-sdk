//
//  AppDelegate.h
//  PushNotificationsApp
//

#import <Cocoa/Cocoa.h>
#import <Pushwoosh/Pushwoosh.h>
#import <Pushwoosh/PWGDPRManager.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, PWMessagingDelegate> {
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextField *lblPushStatus;
@property (assign) IBOutlet NSTextField *lblPushToken;
@property (assign) IBOutlet NSTextField *lblPushPayload;

@end
