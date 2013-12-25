//
//  PushNotificationManager.h
//  Pushwoosh SDK
//  (c) Pushwoosh 2012
//

#import <Foundation/Foundation.h>
#import "PushRuntime.h"

@class PushNotificationManager;

typedef void(^pushwooshGetTagsHandler)(NSDictionary *tags);
typedef void(^pushwooshErrorHandler)(NSError *error);

@protocol PushNotificationDelegate

@optional
//succesfully registered for push notifications
- (void) onDidRegisterForRemoteNotificationsWithDeviceToken:(NSString *)token;

//failed to register for push notifications
- (void) onDidFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

//handle push notification, display alert, if this method is implemented onPushAccepted will not be called, internal message boxes will not be displayed
- (void) onPushReceived:(PushNotificationManager *)pushManager withNotification:(NSDictionary *)pushNotification onStart:(BOOL)onStart;

//user pressed OK on the push notification
- (void) onPushAccepted:(PushNotificationManager *)pushManager withNotification:(NSDictionary *)pushNotification;

//user pressed OK on the push notification
- (void) onPushAccepted:(PushNotificationManager *)pushManager withNotification:(NSDictionary *)pushNotification onStart:(BOOL)onStart;

//received tags from the server
- (void) onTagsReceived:(NSDictionary *)tags;

//error receiving tags from the server
- (void) onTagsFailedToReceive:(NSError *)error;
@end

@interface PWTags : NSObject
+ (NSDictionary *) incrementalTagWithInteger:(NSInteger)delta;
@end

@interface PushNotificationManager : NSObject {
	NSString *appCode;
	NSString *appName;

	NSInteger internalIndex;
	NSMutableDictionary *pushNotifications;
	NSObject<PushNotificationDelegate> *delegate;
}

@property (nonatomic, copy) NSString *appCode;
@property (nonatomic, copy) NSString *appName;
@property (nonatomic, retain) NSDictionary *pushNotifications;
@property (nonatomic, assign) NSObject<PushNotificationDelegate> *delegate;

+ (void)initializeWithAppCode:(NSString *)appCode appName:(NSString *)appName;

+ (PushNotificationManager *)pushManager;

- (id) initWithApplicationCode:(NSString *)appCode appName:(NSString *)appName;

//send tags to server
- (void) setTags: (NSDictionary *) tags;

//get tags from server, calls delegate method if exists
- (void) loadTags;

//get tags from server, calls delegate method if exists and handler (block)
- (void) loadTags: (pushwooshGetTagsHandler) successHandler error:(pushwooshErrorHandler) errorHandler;

//records application open
- (void) sendAppOpen;

//sends current badge value to server
- (void) sendBadges: (NSInteger) badge;

//records stats for a goal in the application, like purchase e.t.c.
- (void) recordGoal: (NSString *) goal;

//same as above plus additional count parameter
- (void) recordGoal: (NSString *) goal withCount: (NSNumber *) count;

//sends the token to server
- (void) handlePushRegistration:(NSData *)devToken;
- (void) handlePushRegistrationString:(NSString *)deviceID;
- (NSString *) getPushToken;

//internal
- (void) handlePushRegistrationFailure:(NSError *) error;

//if the push is received when the app is running
- (BOOL) handlePushReceived:(NSDictionary *) userInfo;

//gets apn payload
- (NSDictionary *) getApnPayload:(NSDictionary *)pushNotification;

//get custom data from the push payload
- (NSString *) getCustomPushData:(NSDictionary *)pushNotification;

@end