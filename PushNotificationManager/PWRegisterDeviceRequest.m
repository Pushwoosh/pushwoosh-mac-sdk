//
//  PWRegisterDeviceRequest
//  Pushwoosh SDK
//  (c) Pushwoosh 2012
//

#import "PWRegisterDeviceRequest.h"

@implementation PWRegisterDeviceRequest
@synthesize pushToken, language, timeZone;


- (NSString *) methodName {
	return @"registerDevice";
}

- (NSDictionary *) requestDictionary {
	NSMutableDictionary *dict = [self baseDictionary];
	
	[dict setObject:[NSNumber numberWithInt:7] forKey:@"device_type"];
	[dict setObject:pushToken forKey:@"push_token"];
	[dict setObject:language forKey:@"language"];
	[dict setObject:timeZone forKey:@"timezone"];

	NSString * package = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
	[dict setObject:package forKey:@"package"];
	
	return dict;
}

- (void) dealloc {
	self.pushToken = nil;
	self.language = nil;
	self.timeZone = nil;

	[super dealloc];
}

@end
