//
//  PushRuntime.m
//  Pushwoosh SDK
//  (c) Pushwoosh 2012
//

#import "PushRuntime.h"
#import "PushNotificationManager.h"
#import <objc/runtime.h>

@implementation NSApplication(Pushwoosh)

void dynamicDidFinishLaunching(id self, SEL _cmd, id aNotification);
void dynamicDidRegisterForRemoteNotificationsWithDeviceToken(id self, SEL _cmd, id application, id devToken);
void dynamicDidFailToRegisterForRemoteNotificationsWithError(id self, SEL _cmd, id application, id error);
void dynamicDidReceiveRemoteNotification(id self, SEL _cmd, id application, id userInfo);

void dynamicDidFinishLaunching(id self, SEL _cmd, id aNotification) {
	if ([self respondsToSelector:@selector(pw_applicationDidFinishLaunching:)]) {
		[self pw_applicationDidFinishLaunching:aNotification];
	}
	
	[[NSApplication sharedApplication] registerForRemoteNotificationTypes:(NSRemoteNotificationTypeBadge | NSRemoteNotificationTypeSound | NSRemoteNotificationTypeAlert)];
	
	if(![PushNotificationManager pushManager].delegate) {
		[PushNotificationManager pushManager].delegate = (NSObject<PushNotificationDelegate> *)self;
	}
	
	[[PushNotificationManager pushManager] handlePushReceived:[aNotification userInfo]];
	[[PushNotificationManager pushManager] sendAppOpen];
}

void dynamicDidRegisterForRemoteNotificationsWithDeviceToken(id self, SEL _cmd, id application, id devToken) {
	if ([self respondsToSelector:@selector(application:pw_didRegisterForRemoteNotificationsWithDeviceToken:)]) {
		[self application:application pw_didRegisterForRemoteNotificationsWithDeviceToken:devToken];
	}
	
	[[PushNotificationManager pushManager] handlePushRegistration:devToken];
}

void dynamicDidFailToRegisterForRemoteNotificationsWithError(id self, SEL _cmd, id application, id error) {
	if ([self respondsToSelector:@selector(application:pw_didFailToRegisterForRemoteNotificationsWithError:)]) {
		[self application:application pw_didFailToRegisterForRemoteNotificationsWithError:error];
	}

	NSLog(@"Error registering for push notifications. Error: %@", error);
	
	[[PushNotificationManager pushManager] handlePushRegistrationFailure:error];
}

void dynamicDidReceiveRemoteNotification(id self, SEL _cmd, id application, id userInfo) {
	if ([self respondsToSelector:@selector(application:pw_didReceiveRemoteNotification:)]) {
		[self application:application pw_didReceiveRemoteNotification:userInfo];
	}

	[[PushNotificationManager pushManager] handlePushReceived:userInfo];
}

- (void) pw_setDelegate:(id<NSApplicationDelegate>)delegate {

	static Class delegateClass = nil;
	
	//do not swizzle the same class twice
	if(delegateClass == [delegate class])
	{
		[self pw_setDelegate:delegate];
		return;
	}
	
	delegateClass = [delegate class];
	
	Method method = nil;
	method = class_getInstanceMethod([delegate class], @selector(applicationDidFinishLaunching:));
	
	if (method) {
		class_addMethod([delegate class], @selector(pw_applicationDidFinishLaunching:), (IMP)dynamicDidFinishLaunching, "v@::");
		method_exchangeImplementations(class_getInstanceMethod([delegate class], @selector(applicationDidFinishLaunching:)), class_getInstanceMethod([delegate class], @selector(pw_applicationDidFinishLaunching:)));
	} else {
		class_addMethod([delegate class], @selector(applicationDidFinishLaunching:), (IMP)dynamicDidFinishLaunching, "v@::");
	}
	
	method = class_getInstanceMethod([delegate class], @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:));
	if(method) {
		class_addMethod([delegate class], @selector(application:pw_didRegisterForRemoteNotificationsWithDeviceToken:), (IMP)dynamicDidRegisterForRemoteNotificationsWithDeviceToken, "v@:::");
		method_exchangeImplementations(class_getInstanceMethod([delegate class], @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:)), class_getInstanceMethod([delegate class], @selector(application:pw_didRegisterForRemoteNotificationsWithDeviceToken:)));
	}
	else {
		class_addMethod([delegate class], @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:), (IMP)dynamicDidRegisterForRemoteNotificationsWithDeviceToken, "v@:::");
	}
	
	method = class_getInstanceMethod([delegate class], @selector(application:didFailToRegisterForRemoteNotificationsWithError:));
	if(method) {
		class_addMethod([delegate class], @selector(application:pw_didFailToRegisterForRemoteNotificationsWithError:), (IMP)dynamicDidFailToRegisterForRemoteNotificationsWithError, "v@:::");
		method_exchangeImplementations(class_getInstanceMethod([delegate class], @selector(application:didFailToRegisterForRemoteNotificationsWithError:)), class_getInstanceMethod([delegate class], @selector(application:pw_didFailToRegisterForRemoteNotificationsWithError:)));
	}
	else {
		class_addMethod([delegate class], @selector(application:didFailToRegisterForRemoteNotificationsWithError:), (IMP)dynamicDidFailToRegisterForRemoteNotificationsWithError, "v@:::");
	}
	
	method = class_getInstanceMethod([delegate class], @selector(application:didReceiveRemoteNotification:));
	if(method) {
		class_addMethod([delegate class], @selector(application:pw_didReceiveRemoteNotification:), (IMP)dynamicDidReceiveRemoteNotification, "v@:::");
		method_exchangeImplementations(class_getInstanceMethod([delegate class], @selector(application:didReceiveRemoteNotification:)), class_getInstanceMethod([delegate class], @selector(application:pw_didReceiveRemoteNotification:)));
	}
	else {
		class_addMethod([delegate class], @selector(application:didReceiveRemoteNotification:), (IMP)dynamicDidReceiveRemoteNotification, "v@:::");
	}
	
	[self pw_setDelegate:delegate];
}

+ (void) load {
	method_exchangeImplementations(class_getInstanceMethod(self, @selector(setDelegate:)), class_getInstanceMethod(self, @selector(pw_setDelegate:)));
}

@end
