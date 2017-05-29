//
//  AppDelegate.m
//  PushNotificationsApp
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	self.lblPushStatus.stringValue = @"Registering";
	
	[NSUserNotificationCenter defaultUserNotificationCenter].delegate = self;
	
	[[PushNotificationManager pushManager] registerForPushNotifications];
	[PushNotificationManager pushManager].delegate = self;
	[[PushNotificationManager pushManager] handlePushReceived:[aNotification userInfo]];
	[[PushNotificationManager pushManager] sendAppOpen];
}

#pragma mark -

// system push notification registration success callback, delegate to pushManager
- (void)application:(NSApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	[[PushNotificationManager pushManager] handlePushRegistration:deviceToken];
}

// system push notification registration error callback, delegate to pushManager
- (void)application:(NSApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	[[PushNotificationManager pushManager] handlePushRegistrationFailure:error];
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
	[[PushNotificationManager pushManager] handlePushReceived:notification.userInfo];
}

- (void) onDidRegisterForRemoteNotificationsWithDeviceToken:(NSString *)token {
	self.lblPushStatus.stringValue = @"Success";
	self.lblPushToken.stringValue = [[PushNotificationManager pushManager] getPushToken];
}

- (void) onDidFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	self.lblPushStatus.stringValue = @"Error";
	self.lblPushToken.stringValue = error.localizedDescription;
}

- (void) onPushAccepted:(PushNotificationManager *)pushManager withNotification:(NSDictionary *)pushNotification onStart:(BOOL)onStart {
	self.lblPushStatus.stringValue = @"Push received";
	self.lblPushPayload.stringValue = pushNotification.description;
}

#pragma mark -

- (void)dealloc {
	[super dealloc];
}

@end
