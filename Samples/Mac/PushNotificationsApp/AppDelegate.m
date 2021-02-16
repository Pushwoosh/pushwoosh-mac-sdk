//
//  AppDelegate.m
//  PushNotificationsApp
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.lblPushStatus.stringValue = @"Registering";
                
    [NSUserNotificationCenter defaultUserNotificationCenter].delegate = [Pushwoosh sharedInstance].notificationCenterDelegateProxy;

    [Pushwoosh sharedInstance].delegate = self;
    
    [[Pushwoosh sharedInstance] handlePushReceived:[aNotification userInfo]];
    [[Pushwoosh sharedInstance] registerForPushNotifications];
}

#pragma mark -

// system push notification registration success callback, delegate to pushManager
- (void)application:(NSApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [[Pushwoosh sharedInstance] handlePushRegistration:deviceToken];
    
    self.lblPushStatus.stringValue = @"Success";
    self.lblPushToken.stringValue = [[Pushwoosh sharedInstance] getPushToken];
}

// system push notification registration error callback, delegate to pushManager
- (void)application:(NSApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    self.lblPushStatus.stringValue = @"Failed to register";
    self.lblPushToken.stringValue = error.localizedDescription;
    [[Pushwoosh sharedInstance] handlePushRegistrationFailure:error];
}

- (void)pushwoosh:(Pushwoosh *)pushwoosh onMessageOpened:(PWMessage *)message {
    self.lblPushStatus.stringValue = @"Push opened";
    self.lblPushPayload.stringValue = [NSString stringWithFormat:@"%@", message.message];
}

- (void)pushwoosh:(Pushwoosh *)pushwoosh onMessageReceived:(PWMessage *)message {
    self.lblPushStatus.stringValue = @"Push received";
    self.lblPushPayload.stringValue = [NSString stringWithFormat:@"%@", message.message];
}

- (IBAction)showGDPRConsentUIButtonAction:(id)sender {
    [[PWGDPRManager sharedManager] showGDPRConsentUI];
}

- (IBAction)showGDPRDeleteUIButtonAction:(id)sender {
    [[PWGDPRManager sharedManager] showGDPRDeletionUI];
}

@end
