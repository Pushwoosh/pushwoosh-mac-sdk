//
//  AppDelegate.m
//  PushNotificationsApp
//

#import "AppDelegate.h"
#import <PushNotificationManager/PushNotificationManager.h>

@implementation AppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	self.lblPushStatus.stringValue = @"Registering";
}

#pragma mark -
#pragma mark PushNotificationDelegate

- (void)onPushAccepted:(PushNotificationManager *)pushManager withNotification:(NSDictionary *)pushNotification {
	NSLog(@"Push accepted");

	self.lblPushStatus.stringValue = @"Push received";
	self.lblPushPayload.stringValue = pushNotification.description;
}

- (void)onDidRegisterForRemoteNotificationsWithDeviceToken:(NSString *)token {
	self.lblPushStatus.stringValue = @"Success";
	self.lblPushToken.stringValue = token;
}

- (void)onDidFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	self.lblPushStatus.stringValue = @"Error";
	self.lblPushToken.stringValue = error.localizedDescription;
}

#pragma mark -

- (void)dealloc {
	[super dealloc];
}

@end
