# PushNotificationManager #

PushNotificationManager class offers access to the singletone-instance of the push manager responsible for registering the device with the APS servers, receiving and processing push notifications.

## Tasks
[appCode](#appcode) *property*  
[appName](#appname) *property*  
[delegate](#delegate) *property*  
[showPushnotificationAlert](#showpushnotificationalert) *property*  

[+ initializeWithAppCode:appName:](#initializewithappcodeappname)  
[+ pushManager](#pushmanager)  
[– registerForPushNotifications](#registerforpushnotifications)  
[– unregisterForPushNotifications](#unregisterforpushnotifications)  
[– startLocationTracking](#startlocationtracking)  
[– stopLocationTracking](#startbeacontracking)  
[– setTags:](#settags)  
[– loadTags](#loadtags)  
[– loadTags:error:](#loadtagserror)  
[– sendAppOpen](#sendappopen)  
[– sendBadges:](#sendbadges)  
[– getPushToken](#getpushtoken)  
[– getHWID](#gethwid)  
[– getApnPayload:](#getapnpayload)  
[– getCustomPushData:](#getcustompushdata)  


## Properties


### appCode

Pushwoosh Application ID. Usually retrieved automatically from `Info.plist` parameter `Pushwoosh_APPID`


```objc
@property (nonatomic, copy) NSString *appCode
```


### appName

Application name. Usually retrieved automatically from `Info.plist` bundle name (CFBundleDisplayName). Could be used to override bundle name. In addition could be set in `Info.plist` as `Pushwoosh_APPNAME` parameter.


```objc
@property (nonatomic, copy) NSString *appName
```

Example logic from Pushwoosh SDK Runtime:

```objc
NSString * appname = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Pushwoosh_APPNAME"];
if(!appname)
	appname = [[NSUserDefaults standardUserDefaults] objectForKey:@"Pushwoosh_APPNAME"];

if(!appname)
	appname = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];

if(!appname)
	appname = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];

if(!appname) {
	appname = @"";
}

instance = [[PushNotificationManager alloc] initWithApplicationCode:appid appName:appname ];
```


### delegate

PushNotificationDelegate protocol delegate that would receive the information about events for push notification manager such as registering with APS services, receiving push notifications or working with the received notification. Pushwoosh Runtime sets it to ApplicationDelegate by default


```objc
@property (nonatomic, assign) NSObject<PushNotificationDelegate> *delegate
```


### showPushnotificationAlert

Show push notifications alert when push notification is received while the app is running, default is YES

```objc
@property (nonatomic, assign) BOOL showPushnotificationAlert
```

## Class Methods


### initializeWithAppCode:appName:

Initializes PushNotificationManager. Usually called by Pushwoosh Runtime internally.

* **appName** - Application name.
* **appcCode** - Pushwoosh App ID.

```objc
+ (void)initializeWithAppCode:(NSString *)appCode appName:(NSString *)appName
```

### pushManager

Returns an object representing the current push manager.

* **Return Value** - A singleton object that represents the push manager.

```objc
+ (PushNotificationManager *)pushManager
```

## Instance Methods

### getApnPayload:

Gets APN payload from push notifications dictionary.

```objc
- (NSDictionary *)getApnPayload:(NSDictionary *)pushNotification
```

* **pushNotification** - Push notifications dictionary as received in `onPushAccepted: withNotification: onStart:`

Example:
```objc
- (void) onPushAccepted:(PushNotificationManager *)pushManager withNotification:(NSDictionary *)pushNotification onStart:(BOOL)onStart {
    NSDictionary * apnPayload = [[PushNotificationsManager pushManager] getApnPayload:pushNotification];
    NSLog(@"%@", apnPayload);
}
```

For Push dictionary sample:
```
{
    aps =     {
        alert = "Some text.";
        sound = default;
    };
    p = 1pb;
}
```

Result is:
```
{
    alert = "Some text.";
    sound = default;
}
```

### getCustomPushData:

Gets custom JSON string data from push notifications dictionary as specified in Pushwoosh Control Panel.

```objc
- (NSString *)getCustomPushData:(NSDictionary *)pushNotification
```

* **pushNotification** - Push notifications dictionary as received in `onPushAccepted: withNotification: onStart:`

Example:
```objc
- (void) onPushAccepted:(PushNotificationManager *)pushManager withNotification:(NSDictionary *)pushNotification onStart:(BOOL)onStart {
    NSString * customData = [[PushNotificationsManager pushManager] getCustomPushData:pushNotification];
    NSLog(@"%@", customData);
}
```

### getHWID

Gets HWID. Unique device identifier that used in all API calls with Pushwoosh. This is identifierForVendor for iOS >= 7.

```objc
- (NSString *)getHWID
```

* **Return Value** - Unique device identifier.

### getPushToken

Gets current push token.

```objc
- (NSString *)getPushToken
```

* **Return Value** - Current push token. May be nil if no push token is available yet.

### loadTags

Get tags from the server. Calls `delegate` method `onTagsReceived:` or `onTagsFailedToReceive:` depending on the results.

```objc
- (void)loadTags
```

### loadTags:error:

Get tags from server. Calls `delegate` method if exists and handler (block).

```objc
- (void)loadTags:(pushwooshGetTagsHandler)successHandler error:(pushwooshErrorHandler)errorHandler
```

* **successHandler** - The block is executed on the successful completion of the request. This block has no return value and takes one argument: the dictionary representation of the recieved tags. Example of the dictionary representation of the received tags:
```
{
    Country = us;
    Language = en;
}
```
* **errorHandler** - The block is executed on the unsuccessful completion of the request. This block has no return value and takes one argument: the error that occurred during the request.

### registerForPushNotifications

Registers for push notifications. By default registeres for `UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert` flags. Automatically detects if you have `newsstand-content` in `UIBackgroundModes` and adds `UIRemoteNotificationTypeNewsstandContentAvailability` flag.

```objc
- (void)registerForPushNotifications
```

### sendAppOpen

Informs the Pushwoosh about the app being launched. Usually called internally by SDK Runtime.

```objc
- (void)sendAppOpen
```

### sendBadges:

Sends current badge value to server. Called internally by SDK Runtime when `UIApplication setApplicationBadgeNumber:` is set. This function is used for “auto-incremeting” badges to work. This way Pushwoosh server can know what current badge value is set for the application.

```objc
- (void)sendBadges:(NSInteger)badge
```

### setTags:

Send tags to server. Tag names have to be created in the Pushwoosh Control Panel. Possible tag types: Integer, String, Incremental (integer only), List tags (array of values).

```objc
- (void)setTags:(NSDictionary *)tags
```

* **tags** - Dictionary representation of tags to send.

Example:
```objc
NSDictionary *tags = [NSDictionary dictionaryWithObjectsAndKeys:
                         aliasField.text, @"Alias",
                         [NSNumber numberWithInt:[favNumField.text intValue]], @"FavNumber",
                         [PWTags incrementalTagWithInteger:5], @"price",
                         [NSArray arrayWithObjects:@"Item1", @"Item2", @"Item3", nil], @"List",
                         nil];

[[PushNotificationManager pushManager] setTags:tags];
```

### startLocationTracking:

Start location tracking.

```objc
- (void)startLocationTracking
```

### stopLocationTracking:

Stop location tracking.

```objc
- (void)stopLocationTracking
```

### unregisterForPushNotifications:

Unregisters from push notifications. You should call this method in rare circumstances only, such as when a new version of the app drops support for remote notifications. Users can temporarily prevent apps from receiving remote notifications through the Notifications section of the Settings app. Apps unregistered through this method can always re-register.

```objc
- (void)unregisterForPushNotifications
```
