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
#import "ProviderDelegate.h"


// https://chromium.googlesource.com/external/webrtc/+/c5aea65b769993a60d67952e2ea9da372a93782c/webrtc   manual webrtc download
@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize voipRegistry,tlk;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
//    [RTCPeerConnectionFactory initialize];
    
    [self voipRegistration];
    
    
//    [[APIManager sharedManager] getICECredentials];
    
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
        
    }
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
    
    NSString *deviceToken = [[NSString stringWithFormat:@"%@",credentials.token] stringByReplacingOccurrencesOfString:@"<" withString:@""];
    
    deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];

//    [[APIManager sharedManager] updateDevieTokenUsername:@"iPhone" andDeviceId:deviceToken];
    
    [AppPreferences sharedAppPreferences].deviceToken = deviceToken;
    
    NSLog(@"%@", deviceToken);
}

-(void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(PKPushType)type
{
    
}


- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type
{

    NSDictionary* dic = payload.dictionaryPayload;
    
    NSString* notificationType =  [dic valueForKey:@"notificationType"];

    NSString* allowVideo =  [dic valueForKey:@"allowVideo"];

    //NSString* sdpType =[dic valueForKey:@"sdpType"];

    if ([notificationType  isEqualToString: @"SDP"])
    {
        NSLog(@"my sdp");

        NSDictionary* apsDict = [dic objectForKey:@"aps"];
        
        NSString* sdpString =[apsDict valueForKey:@"alert"];

        [self initTLKaddObserverForSDPandCandidate:allowVideo];  // init tlk and add observer for receiver
        
        if (sdpString != nil)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GET_SDP object:payload.dictionaryPayload];
        }
    }
    else
    if ([notificationType  isEqualToString: @"Candidate"])
  
    {
        NSLog(@"my candidate");
        [self initTLKaddObserverForSDPandCandidate:allowVideo];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GET_CANDIDATES object:payload.dictionaryPayload];
            
    }
    else
        if ([notificationType  isEqualToString: @"HangUpCall"])
            
        {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HANG_UP_CALL object:payload.dictionaryPayload];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            
        }
    
    
}

+ (AppDelegate *)sharedAppDelegate
{
    return [[UIApplication sharedApplication] delegate];
}


-(void)initTLKaddObserverForSDPandCandidate:(NSString*)allowVideo
{
    
    if (self.tlk == nil) // for receiver
    {
        
        NSString* calleeUser = [[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_USER];
        
        if ([allowVideo isEqualToString:@"1"])
        {
            self.tlk = [[TLKWebRTC alloc] initWithVideo:true];

        }
        else
        {
            self.tlk = [[TLKWebRTC alloc] initWithVideo:false];

        }
        
        NSLog(@"new tlk created = %@",self.tlk);

        self.tlk.delegate = self;
        
        [self.tlk addPeerConnectionForID:calleeUser iceServerArray:self.serverCredArray];  // init peer connection when receive a call
        

        [[NSNotificationCenter defaultCenter] addObserver:self.tlk
                                                 selector:@selector(setSDPGotFromServer:) name:NOTIFICATION_GET_SDP
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self.tlk
                                                 selector:@selector(setCandidatesGotFromServer:) name:NOTIFICATION_GET_CANDIDATES
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(hangUpCall:) name:NOTIFICATION_HANG_UP_CALL
                                                   object:nil];
    
//        [RTCAudioSession sharedInstance].useManualAudio = YES;
    }
    
    
}

-(void)hangUpCall:(NSNotification*)noti
{
    NSString* currentUser = [[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_USER];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DISMISS_CHATVIEW object:nil];

    [self removePeerConnectionForID:currentUser];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

//    [RTCPeerConnectionFactory dealloc];

}

- (void)removePeerConnectionForID:(NSString *)identifier
{

    RTCPeerConnection* peer = self.tlk.peerConnections[identifier];
    
    [self.tlk.peerConnections removeObjectForKey:identifier];

    [self.tlk.peerToRoleMap removeObjectForKey:identifier];
    
//    if (self.tlk.localMediaStream != nil)
//    {
        peer.delegate = nil;
        
        self.tlk.delegate = nil;
        
        self.tlk.dataChannel = nil;
        
        self.tlk.dataChannel.delegate = nil;
        
        [peer removeStream:self.tlk.localMediaStream];
        
        [peer close];
    
        self.tlk.localMediaStream = nil;

        peer = nil;
    
        [[NSNotificationCenter defaultCenter] removeObserver:self.tlk];
    
//        [[NSNotificationCenter defaultCenter] removeObserver:self];



//        if (self.tlk != nil)
//        {
    NSLog(@"tlk set to nil, tlk = %@", self.tlk);

            self.tlk = nil;
    
//        }
    
//    }
    
}
#pragma mark Signalling:TLK delegate methods

-(void)webRTC:(TLKWebRTC*)tlk didSendSDPOffer:(NSString*)localDescription forPeerWithID:(NSString*)peerId calleeUser:(NSString*)calleeUser allowVideo:(NSString*)allowVideo
{
    [[APIManager sharedManager] sendSDPUsername:peerId SDP:localDescription sdpType:@"offer" calleeUser:calleeUser allowVideo:(NSString*)allowVideo];
    
}

-(void)webRTC:(TLKWebRTC*)tlk didSendSDPAnswer:(NSString*)localDescription forPeerWithID:(NSString*)peerId calleeUser:(NSString*)calleeUser allowVideo:(NSString*)allowVideo
{
    [[APIManager sharedManager] sendSDPUsername:peerId SDP:localDescription sdpType:@"answer" calleeUser:calleeUser allowVideo:(NSString*)allowVideo];
    
}

- (void)webRTC:(TLKWebRTC *)webRTC didSendICECandidate:(RTCIceCandidate *)candidate forPeerWithID:(NSString *)peerID allowVideo:(NSString*)allowVideo
{
    NSMutableArray* iceCandidateArray = [NSMutableArray new];
    NSMutableArray* iceCandidateDictArray = [NSMutableArray new];
    
    [iceCandidateArray addObject:candidate];
    
    NSMutableDictionary* dict = [NSMutableDictionary new];
    
    [dict setObject:candidate.sdpMid forKey:SDP_MID];
    
    [dict setObject:[NSString stringWithFormat:@"%d",candidate.sdpMLineIndex] forKey:SDP_MLINE_INDEX];
    
    [dict setObject:candidate.sdp forKey:CANDIDATE_SDP];
    
    [iceCandidateDictArray addObject:dict];
    
    NSError *error;
    
    NSString* json, *json1;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:iceCandidateDictArray options:NSJSONWritingPrettyPrinted error:&error];
    
    if (! jsonData)
    {
        
    }
    else
    {
        json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableDictionary* dict1 = [NSMutableDictionary new];
    
    [dict1 setValue:json forKey:@"dict"];
    
    NSData *jsonData1 = [NSJSONSerialization dataWithJSONObject:dict1 options:NSJSONWritingPrettyPrinted error:&error];
    
    if (! jsonData1)
    {
        return;
    }
    else
    {
        json1 = [[NSString alloc] initWithData:jsonData1 encoding:NSUTF8StringEncoding];
    }
//    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
//    {
        [[APIManager sharedManager] sendCandidateUsername:peerID candidate:json1 allowVideo:(NSString*)allowVideo];
//    }
//    else
//    {
//        [[APIManager sharedManager] sendCandidateUsername:@"iPhone" candidate:json1];
//    }
}


- (void)webRTC:(TLKWebRTC *)webRTC sendCachedICECandidate:(NSMutableArray *)candidateArray forPeerWithID:(NSString *)peerID
{
    
}
- (void)webRTC:(TLKWebRTC *)webRTC didObserveICEConnectionStateChange:(RTCIceConnectionState)state forPeerWithID:(NSString *)peerID
{
//    if (state == 2 || state == 3)
//    {
    NSDictionary* notiDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)state],@"ConnectionState",webRTC.sdpSender,@"ConnectedPeerName",webRTC.dataChannel, @"DataChannel", nil];

        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RTC_COONECTION_CHANGED object:notiDict];
//    }
//    else
//    if (state == 5 || state == 4)
//    {
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RTC_COONECTION_CHANGED object:@"DisConnectedOrFailed"];
//
//    }
    NSLog(@"my state = %d", state);
    
    NSLog(@"my id = %@", peerID);
}

- (void)webRTC:(TLKWebRTC *)webRTC addedStream:(RTCMediaStream *)stream forPeerWithID:(NSString *)peerID
{
    NSDictionary * notiDict = [[NSDictionary alloc] initWithObjectsAndKeys:stream,@"Stream", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NEW_STREAM_RECEIVED object:notiDict];
}

- (void)webRTC:(TLKWebRTC *)webRTC removedStream:(RTCMediaStream *)stream forPeerWithID:(NSString *)peerID
{
    
}

- (void)peerConnection:(TLKWebRTC* )webRTC peerConnection:(RTCPeerConnection *)peerConnection openedDataChannel:(RTCDataChannel *)dataChannel;
{
    NSDictionary * notiDict = [[NSDictionary alloc] initWithObjectsAndKeys:dataChannel,@"DataChannel", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DATA_CHANNEL_OPENED object:notiDict];

}

//-(void) setICEServersGotFromXIR:(NSNotification *)notification
//{
//    NSDictionary* dic = notification.object;
//
//    NSDictionary* vDict = [dic objectForKey:@"v"];
//
//    NSArray* iceServersDict = [vDict valueForKey:@"iceServers"];
//
//    self.serverCredArray = [NSMutableArray new];
//
//    for (NSDictionary* serverCredDict in iceServersDict)
//    {
//        //        NSString* url = [serverCredDict valueForKey:@"url"];
//        //        NSString* username = [serverCredDict valueForKey:@"username"];
//        //        NSString* credential = [serverCredDict valueForKey:@"credential"];
//
//        [self.serverCredArray addObject:serverCredDict];
//    }
//}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    [RTCPeerConnectionFactory dealloc];
}

@end
