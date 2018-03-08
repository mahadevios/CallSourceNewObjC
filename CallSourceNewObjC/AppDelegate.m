//
//  AppDelegate.m
//  CallSourceNewObjC
//
//  Created by mac on 05/10/17.
//  Copyright © 2017 Xanadutec. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize voipRegistry;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [RTCPeerConnectionFactory initializeSSL];
    
    [self voipRegistration];
    
//    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
//    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//    
//    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
//    
//    self.window.rootViewController = viewController;
//    
//    [self.window makeKeyAndVisible];
//    
//    return YES;
    //[RTCPeerConnectionFactory initialize];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [RTCPeerConnectionFactory deinitializeSSL];
    

}



// Register for VoIP notifications
- (void) voipRegistration
{
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    // Create a push registry object
    voipRegistry = [[PKPushRegistry alloc] initWithQueue: mainQueue];
    
    // Set the push type to VoIP
    voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];

    // Set the registry's delegate to self
    voipRegistry.delegate = self;
}

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials: (PKPushCredentials *)credentials forType:(NSString *)type
{
    NSLog(@"PushCredentials: %@", credentials.token);
   // NSString* token = [[NSString alloc] initWithData:credentials.token encoding:NSUTF8StringEncoding];
    NSString *deviceToken = [[NSString stringWithFormat:@"%@",credentials.token] stringByReplacingOccurrencesOfString:@"<" withString:@""];
    deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];

    [[APIManager sharedManager] updateDevieTokenUsername:@"iPhone" andDeviceId:deviceToken];
    
    //[[APIManager sharedManager] updateDevieTokenUsername:@"iPad" andDeviceId:deviceToken];

    [AppPreferences sharedAppPreferences].deviceToken = deviceToken;
    
    NSLog(@"%@", deviceToken);
    // Register VoIP push token (a property of PKPushCredentials) with server
}

-(void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(PKPushType)type
{
    
}


- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type
{
    // Process the received push
//    NSLog(@"%@", payload);
    
    NSDictionary* dic = payload.dictionaryPayload;
    NSString* notificationType =  [dic valueForKey:@"notificationType"];

    if ([notificationType  isEqual: @"SDP"])
    {
        //NSLog(@"got sdp noti");
        NSDictionary* apsDict = [dic objectForKey:@"aps"];
        [apsDict valueForKey:@"alert"];
        NSString* sdpString =[apsDict valueForKey:@"alert"];
        
        if (sdpString != nil)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GET_SDP object:payload.dictionaryPayload];
            
        }

    }
    else
        if ([notificationType  isEqual: @"Candidate"])
  
    {
        //NSLog(@"got candidate noti");

        NSDictionary* apsDict = [dic objectForKey:@"aps"];

            NSString* candidateString = [apsDict valueForKey:@"alert"];

            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GET_CANDIDATES object:payload.dictionaryPayload];
            
    }
    
//    UILocalNotification* notif = [[UILocalNotification alloc] init];
//    notif.alertBody = @"incoming call";
//    [[UIApplication sharedApplication] presentLocalNotificationNow:notif];
    
}

@end
