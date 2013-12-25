//
//  PushNotificationManager.m
//  Pushwoosh SDK
//  (c) Pushwoosh 2012
//

#import "PushNotificationManager.h"
#import <IOKit/IOKitLib.h>

#import "PWRequestManager.h"
#import "PWRegisterDeviceRequest.h"
#import "PWSetTagsRequest.h"
#import "PWGetTagsRequest.h"
#import "PWSendBadgeRequest.h"
#import "PWAppOpenRequest.h"
#import "PWPushStatRequest.h"
#import "PWApplicationEventRequest.h"

#define kServiceHtmlContentFormatUrl @"http://cp.pushwoosh.com/content/%@"

@implementation PWTags
+ (NSDictionary *) incrementalTagWithInteger:(NSInteger)delta {
	return [NSMutableDictionary dictionaryWithObjectsAndKeys:@"increment", @"operation", [NSNumber numberWithLong:delta], @"value", nil];
}
@end

@implementation PushNotificationManager

@synthesize appCode, appName, pushNotifications, delegate;

static NSData * GetMACAddress()
{
    kern_return_t           kr          = KERN_SUCCESS;
    CFMutableDictionaryRef  matching    = NULL;
    io_iterator_t           iterator    = IO_OBJECT_NULL;
    io_object_t             service     = IO_OBJECT_NULL;
    CFDataRef               result      = NULL;
	
    matching = IOBSDNameMatching( kIOMasterPortDefault, 0, "en0" );
    if ( matching == NULL )
    {
        fprintf( stderr, "IOBSDNameMatching() returned empty dictionary\n" );
        return ( NULL );
    }
	
    kr = IOServiceGetMatchingServices( kIOMasterPortDefault, matching, &iterator );
    if ( kr != KERN_SUCCESS )
    {
        fprintf( stderr, "IOServiceGetMatchingServices() returned %d\n", kr );
        return ( NULL );
    }
	
    while ( (service = IOIteratorNext(iterator)) != IO_OBJECT_NULL )
    {
        io_object_t parent = IO_OBJECT_NULL;
		
        kr = IORegistryEntryGetParentEntry( service, kIOServicePlane, &parent );
        if ( kr == KERN_SUCCESS )
        {
            if ( result != NULL )
                CFRelease( result );
			
            result = IORegistryEntryCreateCFProperty( parent, CFSTR("IOMACAddress"), kCFAllocatorDefault, 0 );
            IOObjectRelease( parent );
        }
        else
        {
            fprintf( stderr, "IORegistryGetParentEntry returned %d\n", kr );
        }
		
        IOObjectRelease( service );
    }
	
    return ( (NSData *)NSMakeCollectable(result) );
}

static NSString * GetMACAddressDisplayString()
{
    NSData * macData = GetMACAddress();
    if ( [macData length] == 0 )
        return ( nil );
	
    const UInt8 *bytes = [macData bytes];
	
    NSMutableString * result = [NSMutableString string];
    for ( NSUInteger i = 0; i < [macData length]; i++ )
    {
        if ( [result length] != 0 )
            [result appendFormat: @"%02hhx", bytes[i]];
        else
            [result appendFormat: @"%02hhx", bytes[i]];
    }
	
    return ( [[result copy] autorelease] );
}

- (id) initWithApplicationCode:(NSString *)_appCode appName:(NSString *)_appName{
	if(self = [super init]) {
		self.appCode = _appCode;
		self.appName = _appName;
		
		[[NSUserDefaults standardUserDefaults] setObject:_appCode forKey:@"Pushwoosh_APPID"];
		if(_appName) {
			[[NSUserDefaults standardUserDefaults] setObject:_appName forKey:@"Pushwoosh_APPNAME"];
		}
	}
	
	return self;
}

+ (void)initializeWithAppCode:(NSString *)appCode appName:(NSString *)appName {
	[[NSUserDefaults standardUserDefaults] setObject:appCode forKey:@"Pushwoosh_APPID"];
	
	if(appName) {
		[[NSUserDefaults standardUserDefaults] setObject:appName forKey:@"Pushwoosh_APPNAME"];
	}
}

+ (PushNotificationManager *)pushManager {
	static PushNotificationManager * instance = nil;
	
	if(instance == nil) {
		NSString * appid = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Pushwoosh_APPID"];
		
		if(!appid) {
			appid = [[NSUserDefaults standardUserDefaults] objectForKey:@"Pushwoosh_APPID"];

			if(!appid) {
				return nil;
			}
		}
		
		NSString * appname = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
		if(!appname) {
			appname = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
			
			if(!appname) {
				appname = @"";
			}
		}
		
		instance = [[PushNotificationManager alloc] initWithApplicationCode:appid appName:appname ];
	}
	
	return instance;
}

// Mac SDK does not have RICH pushes support yet
- (void) showPushPage:(NSString *)pageId {
//	NSString *url = [NSString stringWithFormat:kServiceHtmlContentFormatUrl, pageId];
}

- (void) sendDevTokenToServer:(NSString *)deviceID {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	NSString * appLocale = @"en";
	NSLocale * locale = (NSLocale *)CFLocaleCopyCurrent();
	NSString * localeId = [locale localeIdentifier];
	
	if([localeId length] > 2)
		localeId = [localeId stringByReplacingCharactersInRange:NSMakeRange(2, [localeId length]-2) withString:@""];
	
	[locale release]; locale = nil;
	
	appLocale = localeId;
	
	NSArray * languagesArr = (NSArray *) CFLocaleCopyPreferredLanguages();	
	if([languagesArr count] > 0)
	{
		NSString * value = [languagesArr objectAtIndex:0];
		
		if([value length] > 2)
			value = [value stringByReplacingCharactersInRange:NSMakeRange(2, [value length]-2) withString:@""];
		
		appLocale = [[value copy] autorelease];
	}
	
	[languagesArr release]; languagesArr = nil;
	
	PWRegisterDeviceRequest *request = [[PWRegisterDeviceRequest alloc] init];
	request.appId = appCode;
	request.hwid = GetMACAddressDisplayString();
	request.pushToken = deviceID;
	request.language = appLocale;
	request.timeZone = [NSString stringWithFormat:@"%ld", [[NSTimeZone localTimeZone] secondsFromGMT]];
	
	NSError *error = nil;
	if ([[PWRequestManager sharedManager] sendRequest:request error:&error]) {
		NSLog(@"Registered for push notifications: %@", deviceID);

		if([delegate respondsToSelector:@selector(onDidRegisterForRemoteNotificationsWithDeviceToken:)] ) {
			[delegate performSelectorOnMainThread:@selector(onDidRegisterForRemoteNotificationsWithDeviceToken:) withObject:[self getPushToken] waitUntilDone:NO];
		}
	} else {
		NSLog(@"Registered for push notifications failed");

		if([delegate respondsToSelector:@selector(onDidFailToRegisterForRemoteNotificationsWithError:)] ) {
			[delegate performSelectorOnMainThread:@selector(onDidFailToRegisterForRemoteNotificationsWithError:) withObject:error waitUntilDone:NO];
		}
	}
	
	[request release]; request = nil;
	[pool release]; pool = nil;
}

- (void) handlePushRegistrationString:(NSString *)deviceID {
	
	[[NSUserDefaults standardUserDefaults] setObject:deviceID forKey:@"PWPushUserId"];
	
	[self performSelectorInBackground:@selector(sendDevTokenToServer:) withObject:deviceID];
}

- (void) handlePushRegistration:(NSData *)devToken {
	NSMutableString *deviceID = [NSMutableString stringWithString:[devToken description]];
	
	//Remove <, >, and spaces
	[deviceID replaceOccurrencesOfString:@"<" withString:@"" options:1 range:NSMakeRange(0, [deviceID length])];
	[deviceID replaceOccurrencesOfString:@">" withString:@"" options:1 range:NSMakeRange(0, [deviceID length])];
	[deviceID replaceOccurrencesOfString:@" " withString:@"" options:1 range:NSMakeRange(0, [deviceID length])];
	
	[[NSUserDefaults standardUserDefaults] setObject:deviceID forKey:@"PWPushUserId"];
	
	[self performSelectorInBackground:@selector(sendDevTokenToServer:) withObject:deviceID];
}

- (void) handlePushRegistrationFailure:(NSError *) error {
	if([delegate respondsToSelector:@selector(onDidFailToRegisterForRemoteNotificationsWithError:)] ) {
		[delegate performSelectorOnMainThread:@selector(onDidFailToRegisterForRemoteNotificationsWithError:) withObject:error waitUntilDone:NO];
	}
}

- (NSString *) getPushToken {
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"PWPushUserId"];
}

- (BOOL) handlePushReceived:(NSDictionary *)userInfo {
	//set the application badges icon to 0
	[[[NSApplication sharedApplication] dockTile] setBadgeLabel:@""];
	
	BOOL isPushOnStart = NO;
	NSDictionary *pushDict = [userInfo objectForKey:@"aps"];
	if(!pushDict) {
		//try as launchOptions dictionary
		userInfo = [userInfo objectForKey:NSApplicationLaunchRemoteNotificationKey];
		pushDict = [userInfo objectForKey:@"aps"];
		isPushOnStart = YES;
	}
	
	if (!pushDict)
		return NO;

	//on mac only active application can receive push notification at this time
	isPushOnStart = NO;
	
	NSString *hash = [userInfo objectForKey:@"p"];
	
	[self performSelectorInBackground:@selector(sendStatsBackground:) withObject:hash];
	
	if([delegate respondsToSelector:@selector(onPushReceived: withNotification: onStart:)] ) {
		[delegate onPushReceived:self withNotification:userInfo onStart:isPushOnStart];
		return YES;
	}

	NSString *alertMsg = [pushDict objectForKey:@"alert"];
//	NSString *badge = [pushDict objectForKey:@"badge"];
//	NSString *sound = [pushDict objectForKey:@"sound"];
	NSString *htmlPageId = [userInfo objectForKey:@"h"];
//	NSString *customData = [userInfo objectForKey:@"u"];
	NSString *linkUrl = [userInfo objectForKey:@"l"];
	
	//the app is running, display alert only
	if(!isPushOnStart) {
		NSAlert *alert = [NSAlert alertWithMessageText:self.appName defaultButton:@"OK" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"%@", alertMsg];
		[alert setAlertStyle:NSInformationalAlertStyle];
		
		if ([alert runModal] != NSAlertDefaultReturn)
			return NO;
	}
	
	if(htmlPageId) {
		[self showPushPage:htmlPageId];
	}
    
	if(linkUrl) {
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:linkUrl]];
	}

	if([delegate respondsToSelector:@selector(onPushAccepted: withNotification:)] ) {
		[delegate onPushAccepted:self withNotification:userInfo];
	}
	else
	if([delegate respondsToSelector:@selector(onPushAccepted: withNotification: onStart:)] ) {
		[delegate onPushAccepted:self withNotification:userInfo onStart:isPushOnStart];
	}

	return YES;
}

- (NSDictionary *) getApnPayload:(NSDictionary *)pushNotification {
	return [pushNotification objectForKey:@"aps"];
}

- (NSString *) getCustomPushData:(NSDictionary *)pushNotification {
	return [pushNotification objectForKey:@"u"];
}

- (void) sendStatsBackground:(NSString *)hash {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	PWPushStatRequest *request = [[PWPushStatRequest alloc] init];
	request.appId = appCode;
	request.hash = hash;
	request.hwid = GetMACAddressDisplayString();

	if ([[PWRequestManager sharedManager] sendRequest:request]) {
		NSLog(@"sendStats completed");
	} else {
		NSLog(@"sendStats failed");
	}
	
	[request release]; request = nil;
	
	[pool release]; pool = nil;
}

- (void) sendTagsBackground: (NSDictionary *) tags {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    PWSetTagsRequest *request = [[PWSetTagsRequest alloc] init];
	request.appId = appCode;
	request.hwid = GetMACAddressDisplayString();
    request.tags = tags;
	
	if ([[PWRequestManager sharedManager] sendRequest:request]) {
		NSLog(@"setTags completed");
	} else {
		NSLog(@"setTags failed");
	}
	
	[request release]; request = nil;

	[pool release]; pool = nil;
}

- (void) sendAppOpenBackground {
	//it's ok to call this method without push token
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	PWAppOpenRequest *request = [[PWAppOpenRequest alloc] init];
	request.appId = appCode;
	request.hwid = GetMACAddressDisplayString();
	
	if ([[PWRequestManager sharedManager] sendRequest:request]) {
		NSLog(@"sending appOpen completed");
	} else {
		NSLog(@"sending appOpen failed");
	}
	
	[request release]; request = nil;
	[pool release]; pool = nil;
}

- (void) sendBadgesBackground: (NSNumber *) badge {
	if([[PushNotificationManager pushManager] getPushToken] == nil)
		return;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	PWSendBadgeRequest *request = [[PWSendBadgeRequest alloc] init];
	request.appId = appCode;
	request.hwid = GetMACAddressDisplayString();
	request.badge = [badge intValue];
		
	if ([[PWRequestManager sharedManager] sendRequest:request]) {
		NSLog(@"setBadges completed");
	} else {
		NSLog(@"setBadges failed");
	}
	
	[request release]; request = nil;
	[pool release]; pool = nil;
}

- (void) sendGoalBackground: (PWApplicationEventRequest *) request {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if ([[PWRequestManager sharedManager] sendRequest:request]) {
		NSLog(@"sendGoals completed");
	} else {
		NSLog(@"sendGoals failed");
	}

	[pool release]; pool = nil;
}

- (void) sendBadges: (NSInteger) badge {
	[self performSelectorInBackground:@selector(sendBadgesBackground:) withObject:[NSNumber numberWithLong:badge]];
}

- (void) sendAppOpen {
	[self performSelectorInBackground:@selector(sendAppOpenBackground) withObject:nil];
}

- (void) setTags: (NSDictionary *) tags {
	[self performSelectorInBackground:@selector(sendTagsBackground:) withObject:tags];
}

- (void) loadTags {
	[self loadTags:nil error:nil];
}

- (void) loadTags: (pushwooshGetTagsHandler) successHandler error:(pushwooshErrorHandler) errorHandler{
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
	dispatch_async(queue, ^{
		PWGetTagsRequest *request = [[PWGetTagsRequest alloc] init];
		request.appId = appCode;
		request.hwid = GetMACAddressDisplayString();
		
		NSError *error = nil;
		if ([[PWRequestManager sharedManager] sendRequest:request error:&error]) {
			NSLog(@"loadTags completed");
			
			dispatch_async(dispatch_get_main_queue(), ^{
				if([delegate respondsToSelector:@selector(onTagsReceived:)] ) {
					[delegate onTagsReceived:request.tags];
				}
				
				if(successHandler) {
					successHandler(request.tags);
				}
			});
			
		} else {
			NSLog(@"loadTags failed");
			
			dispatch_async(dispatch_get_main_queue(), ^{
				if([delegate respondsToSelector:@selector(onTagsFailedToReceive:)] ) {
					[delegate onTagsFailedToReceive:error];
				}
				
				if(errorHandler) {
					errorHandler(error);
				}
			});
		}
		
		[request release]; request = nil;
	});
}

- (void) recordGoal: (NSString *) goal {
	[self recordGoal:goal withCount:nil];
}

- (void) recordGoal: (NSString *) goal withCount: (NSNumber *) count {
	PWApplicationEventRequest *request = [[PWApplicationEventRequest alloc] init];
	request.appId = appCode;
	request.hwid = GetMACAddressDisplayString();
	request.goal = goal;
	request.count = count;

	[self performSelectorInBackground:@selector(sendGoalBackground:) withObject:request];
	[request release];
}

- (void) dealloc {
	self.delegate = nil;
	self.appCode = nil;
	self.pushNotifications = nil;
	
	[super dealloc];
}

@end