//
//  AppDelegate.h
//  PushNotificationsApp
//

#import <Cocoa/Cocoa.h>
#import <Pushwoosh/PushNotificationManager.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate, PushNotificationDelegate> {
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextField *lblPushStatus;
@property (assign) IBOutlet NSTextField *lblPushToken;
@property (assign) IBOutlet NSTextField *lblPushPayload;

@end
