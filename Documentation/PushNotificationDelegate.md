# PushNotificationDelegate Protocol #

`PushNotificationDelegate` protocol defines the methods that can be implemented in the delegate of the `PushNotificationManager` class' singleton object. These methods provide information about the key events for push notification manager such as registering with APS services, receiving push notifications or working with the received notification. These methods implementation allows to react on these events properly.

## Tasks
[– onDidRegisterForRemoteNotificationsWithDeviceToken:](#ondidregisterforremotenotificationswithdevicetoken)  
[– onDidFailToRegisterForRemoteNotificationsWithError:](#ondidfailtoregisterforremotenotificationswitherror)  
[– onPushReceived:withNotification:onStart:](#onpushreceivedwithnotificationonstart)  
[– onPushAccepted:withNotification:](#onpushacceptedwithnotification)  
[– onPushAccepted:withNotification:onStart:](#onpushacceptedwithnotificationonstart)  
[– onTagsReceived:](#ontagsreceived)  
[– onTagsFailedToReceive:](#ontagsfailedtoreceive)  


## Instance Methods

### onDidFailToRegisterForRemoteNotificationsWithError:

Sent to the delegate when Apple Push Service (APS) could not complete the registration process successfully.

```objc
- (void)onDidFailToRegisterForRemoteNotificationsWithError:(NSError *)error
```

* **error** - An NSError object encapsulating the information about the reason of the registration failure. Within this method you can define application’s behaviour in case of registration failure.


### onDidRegisterForRemoteNotificationsWithDeviceToken:

Tells the delegate that the application has registered with Apple Push Service (APS) successfully.

```objc
- (void)onDidRegisterForRemoteNotificationsWithDeviceToken:(NSString *)token
```

* **token** - A token used for identifying the device with APS.


### onPushAccepted:withNotification:

Tells the delegate that the user has pressed OK on the push notification. IMPORTANT: This method is used for backwards compatibility and is deprecated. Please use the `onPushAccepted:withNotification:onStart:` method instead

```objc
- (void)onPushAccepted:(PushNotificationManager *)pushManager withNotification:(NSDictionary *)pushNotification
```

### onPushAccepted:withNotification:onStart:

Tells the delegate that the user has pressed OK on the push notification.

```objc
- (void)onPushAccepted:(PushNotificationManager *)pushManager withNotification:(NSDictionary *)pushNotification onStart:(BOOL)onStart
```

* **pushManager** - The push manager that received the remote notification.
* **pushNotification** - A dictionary that contains information about the remote notification, potentially including a badge number for the application icon, an alert sound, an alert message to display to the user, a notification identifier, and custom data. The provider originates it as a JSON-defined dictionary that Mac converts to an NSDictionary object; the dictionary may contain only property-list objects plus NSNull. Push dictionary sample:
```
{
     aps =     {
         alert = "Some text.";
         sound = default;
     };
     p = 1pb;
}
```
* **onStart** - If the application was not active when the push notification was received, the application will be launched with this parameter equal to YES, otherwise the parameter will be NO.


### onPushReceived:withNotification:onStart:

Tells the delegate that the push manager has received a remote notification.

```objc
- (void)onPushReceived:(PushNotificationManager *)pushManager withNotification:(NSDictionary *)pushNotification onStart:(BOOL)onStart
```

* **pushManager** - The push manager that received the remote notification. If this method is implemented `onPushAccepted:withNotification:` will not be called, internal message boxes will not be displayed.

* **pushNotification** - A dictionary that contains information referring to the remote notification, potentially including a badge number for the application icon, an alert sound, an alert message to display to the user, a notification identifier, and custom data. The provider originates it as a JSON-defined dictionary that Mac converts to an NSDictionary object; the dictionary may contain only property-list objects plus NSNull.

* **onStart** - If the application was not active when the push notification was received, the application will be launched with this parameter equal to YES, otherwise the parameter will be NO.

### onTagsFailedToReceive:

Sent to the delegate when push manager could not complete the tags receiving process successfully.

```objc
- (void)onTagsFailedToReceive:(NSError *)error
```

* **error** - An NSError object that encapsulates information why receiving tags did not succeed.

### onTagsReceived:

Tells the delegate that the push manager has received tags from the server.

```objc
- (void)onTagsReceived:(NSDictionary *)tags
```

* **tags** - Dictionary representation of received tags. Dictionary example:
```
{
    Country = us;
    Language = en;
}
```
