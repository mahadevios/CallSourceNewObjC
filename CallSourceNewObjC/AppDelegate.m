//
//  AppDelegate.m
//  CallSourceNewObjC
//
//  Created by mac on 05/10/17.
//  Copyright © 2017 Xanadutec. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "ReigisteredUsersViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize voipRegistry;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [RTCPeerConnectionFactory initializeSSL];
    
    [self voipRegistration];
    
    //[[NSUserDefaults standardUserDefaults] setValue:@"iPad" forKey:USERDEFAULT_USER];
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
    [self checkUserLogin];
    
    return YES;
}

-(void)checkUserLogin
{
    NSString* loggedInUser = [[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_USER];
    
    if ([loggedInUser  isEqualToString: @""] || loggedInUser == NULL)
    {
        
    }
    else
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
        
        ReigisteredUsersViewController* viewController = [storyboard instantiateViewControllerWithIdentifier:@"ReigisteredUsersViewController"];
        
        [self.window setRootViewController:viewController];
        
        //[self.window.rootViewController presentViewController:loginViewController animated:NO completion:nil];
    }
}

-(void)initTLKaddObserverForSDPandCandidate
{
    NSString* calleeUser = [[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_USER];

//    NSString* calleeUser = @"iPad";

    if (self.tlk == nil) // for receiver
    {
        self.tlk = [[TLKWebRTC alloc] init];
        
        self.tlk.delegate = self;
        
        [self.tlk addPeerConnectionForID:calleeUser iceServerArray:self.serverCredArray];
        
        [[NSNotificationCenter defaultCenter] addObserver:self.tlk
                                                 selector:@selector(setSDPGotFromServer:) name:NOTIFICATION_GET_SDP
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self.tlk
                                                 selector:@selector(setCandidatesGotFromServer:) name:NOTIFICATION_GET_CANDIDATES
                                                   object:nil];
    }
//    else
//    {
//        [self.tlk addPeerConnectionForID:calleeUser iceServerArray:self.serverCredArray];
//    }
    
    
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

//    [[APIManager sharedManager] updateDevieTokenUsername:@"iPhone" andDeviceId:deviceToken];
    
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
//    if (self.tlk == nil)
//    {
//        [self initTLKaddObserverForSDPandCandidate];
//    }
    
    NSDictionary* dic = payload.dictionaryPayload;
    
    NSString* notificationType =  [dic valueForKey:@"notificationType"];

    NSString* sdpType =[dic valueForKey:@"sdpType"];

    if ([notificationType  isEqualToString: @"SDP"])
    {
        //NSLog(@"got sdp noti");
        NSDictionary* apsDict = [dic objectForKey:@"aps"];
        
        //RTCSessionDescription *remoteDesc = [apsDict valueForKey:@"alert"];
        NSString* sdpString =[apsDict valueForKey:@"alert"];

//        payload.dictionaryPayload valueForKey:@"sdpSender"
//        if ([sdpType  isEqualToString: @"offer"])  // if offer then init the peerconnection
//        {
             [self initTLKaddObserverForSDPandCandidate];
//        }
        
        if (sdpString != nil)
        {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GET_SDP object:payload.dictionaryPayload];
            
        }

    }
    else
        if ([notificationType  isEqualToString: @"Candidate"])
  
    {
        //NSLog(@"got candidate noti");

        NSDictionary* apsDict = [dic objectForKey:@"aps"];

//            NSString* candidateString = [apsDict valueForKey:@"alert"];

            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GET_CANDIDATES object:payload.dictionaryPayload];
            
    }
    
//    UILocalNotification* notif = [[UILocalNotification alloc] init];
//    notif.alertBody = @"incoming call";
//    [[UIApplication sharedApplication] presentLocalNotificationNow:notif];
    
}


#pragma mark:TLK delegate methods

-(void)webRTC:(TLKWebRTC*)tlk didSendSDPOffer:(RTCSessionDescription*)localDescription forPeerWithID:(NSString*)peerId calleeUser:(NSString*)calleeUser
{
    [[APIManager sharedManager] sendSDPUsername:peerId SDP:localDescription sdpType:@"offer" calleeUser:calleeUser];
    
}

-(void)webRTC:(TLKWebRTC*)tlk didSendSDPAnswer:(RTCSessionDescription*)localDescription forPeerWithID:(NSString*)peerId calleeUser:(NSString*)calleeUser
{
    [[APIManager sharedManager] sendSDPUsername:peerId SDP:localDescription sdpType:@"answer" calleeUser:calleeUser];
    
}

- (void)webRTC:(TLKWebRTC *)webRTC didSendICECandidate:(RTCICECandidate *)candidate forPeerWithID:(NSString *)peerID
{
    NSMutableArray* iceCandidateArray = [NSMutableArray new];
    NSMutableArray* iceCandidateDictArray = [NSMutableArray new];
    
    [iceCandidateArray addObject:candidate];
    
    NSMutableDictionary* dict = [NSMutableDictionary new];
    
    [dict setValue:candidate.sdpMid forKey:SDP_MID];
    [dict setValue:[NSString stringWithFormat:@"%d",candidate.sdpMLineIndex] forKey:SDP_MLINE_INDEX];
    [dict setValue:candidate.sdp forKey:CANDIDATE_SDP];
    
    [iceCandidateDictArray addObject:dict];
    
    
    NSError *error;
    NSString* json, *json1;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:iceCandidateDictArray options:NSJSONWritingPrettyPrinted error:&error];
    
    if (! jsonData) {
        
    } else {
        json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableDictionary* dict1 = [NSMutableDictionary new];
    
    [dict1 setValue:json forKey:@"dict"];
    
    NSData *jsonData1 = [NSJSONSerialization dataWithJSONObject:dict1 options:NSJSONWritingPrettyPrinted error:&error];
    
    if (! jsonData1) {
        return;
    } else {
        json1 = [[NSString alloc] initWithData:jsonData1 encoding:NSUTF8StringEncoding];
    }
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        
        [[APIManager sharedManager] sendCandidateUsername:@"iPad" candidate:json1];
    }
    else
    {
        [[APIManager sharedManager] sendCandidateUsername:@"iPhone" candidate:json1];
    }
}


- (void)webRTC:(TLKWebRTC *)webRTC sendCachedICECandidate:(NSMutableArray *)candidateArray forPeerWithID:(NSString *)peerID
{
    // NSMutableArray* iceCandidateArray = [NSMutableArray new];
    // NSMutableArray* iceCandidateDictArray = [NSMutableArray new];
    
    //[iceCandidateArray addObject:candidate];
    
//    NSMutableDictionary* dict = [NSMutableDictionary new];
//
//    for (RTCICECandidate* candidate in candidateArray)
//    {
//
//        [dict setValue:candidate.sdpMid forKey:SDP_MID];
//        [dict setValue:[NSString stringWithFormat:@"%ld",(long)candidate.sdpMLineIndex] forKey:SDP_MLINE_INDEX];
//        [dict setValue:candidate.sdp forKey:CANDIDATE_SDP];
//
//        [iceCandidateDictArray addObject:dict];
//    }
//
//
//
//    NSError *error;
//    NSString* json, *json1;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:iceCandidateDictArray options:NSJSONWritingPrettyPrinted error:&error];
//
//    if (! jsonData) {
//
//    } else {
//        json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    }
//
//    NSMutableDictionary* dict1 = [NSMutableDictionary new];
//
//    [dict1 setValue:json forKey:@"dict"];
//
//    NSData *jsonData1 = [NSJSONSerialization dataWithJSONObject:dict1 options:NSJSONWritingPrettyPrinted error:&error];
//
//    if (! jsonData1) {
//        return;
//    } else {
//        json1 = [[NSString alloc] initWithData:jsonData1 encoding:NSUTF8StringEncoding];
//    }
//    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
//    {
//
//        [[APIManager sharedManager] sendCandidateUsername:@"iPad" candidate:json1];
//    }
//    else
//    {
//        [[APIManager sharedManager] sendCandidateUsername:@"iPhone" candidate:json1];
//    }
}
- (void)webRTC:(TLKWebRTC *)webRTC didObserveICEConnectionStateChange:(RTCICEConnectionState)state forPeerWithID:(NSString *)peerID
{
    if (state == 2 || state == 3)
    {
//        self.callStatusLabel.hidden = NO;
//        
//        self.callStatusLabel.text = @"Connected";
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RTC_COONECTION_CHANGED object:@"Connected"];
    }
    NSLog(@"my state = %d", state);
    
    NSLog(@"my id = %@", peerID);
}

- (void)webRTC:(TLKWebRTC *)webRTC addedStream:(RTCMediaStream *)stream forPeerWithID:(NSString *)peerID
{
    
}

- (void)webRTC:(TLKWebRTC *)webRTC removedStream:(RTCMediaStream *)stream forPeerWithID:(NSString *)peerID
{
    
}

@end
