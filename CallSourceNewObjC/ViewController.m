//
//  ViewController.m
//  CallSourceNewObjC
//
//  Created by mac on 05/10/17.
//  Copyright © 2017 Xanadutec. All rights reserved.
//


#import "ViewController.h"


@interface ViewController ()



@end

@implementation ViewController

@synthesize factory,peerConn,socket,iceCandidateArray,iceCandidateDictArray,iceCandidateGotFromServerArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   // [self prepareConnectionPeer1:@""];
    
    iceCandidateArray = [NSMutableArray new];
    
    iceCandidateDictArray = [NSMutableArray new];
    
    iceCandidateGotFromServerArray = [NSMutableArray new];

        // Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setICEServersGotFromXIR:) name:NOTIFICATION_GOT_TURN
                                               object:nil];

    [[APIManager sharedManager] getICECredentials];
    
//    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
//    {
//        [self.audioCallButton setHidden:true];
//
//        self.tlk = [[TLKWebRTC alloc] init];
//
//        self.tlk.delegate = self;
//
//        [[NSNotificationCenter defaultCenter] addObserver:self.tlk
//                                                 selector:@selector(setSDPGotFromServer:) name:NOTIFICATION_GET_SDP
//                                                   object:nil];
//
//        [[NSNotificationCenter defaultCenter] addObserver:self.tlk
//                                                 selector:@selector(setCandidatesGotFromServer:) name:NOTIFICATION_GET_CANDIDATES
//                                                   object:nil];
//
//
//        [self.tlk addPeerConnectionForID:@"iPad" iceServerArray:self.serverCredArray];
//    }
    
    
    
}

//-(void) setSDPGotFromServer:(NSNotification *)notification
//{
//    // check for signaling state also
//
//    NSLog(@"conn state = %u",self.peerConn.iceConnectionState);
//    NSLog(@"sig sate = %u",self.peerConn.signalingState);
//
//    NSDictionary* dic = notification.object;
//
//    NSDictionary* apsDict = [dic objectForKey:@"aps"];
//    [apsDict valueForKey:@"alert"];
//    NSString* sdp =[apsDict valueForKey:@"alert"];
//
//
//    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
//    {
//
//        [self handleIncomingOffer:sdp];
//    }
//    else
//    {
//      [self handleIncomingAnswer:sdp];
//    }
//
//}
//
//-(void) setCandidatesGotFromServer:(NSNotification *)notification
//{
//
//    NSDictionary* dic = notification.object;
//    NSDictionary* apsDict = [dic objectForKey:@"aps"];
//    [apsDict valueForKey:@"alert"];
//    NSString* candidates =[apsDict valueForKey:@"alert"];
//
//
//    NSData *data1 = [candidates dataUsingEncoding:NSUTF8StringEncoding];
//    NSError* err;
//    iceCandidateGotFromServerArray = [NSJSONSerialization JSONObjectWithData:data1 options:NSJSONReadingAllowFragments error:&err];
//
//    if (self.peerConn.remoteDescription != nil)
//    {
//        [self setCandidates];
//    }
//
//}
//
//-(void) setCandidates
//{
//    for (int i = 0; i< iceCandidateGotFromServerArray.count; i++)
//    {
//        NSDictionary* dic = iceCandidateGotFromServerArray[i];
//
//        RTCICECandidate *candidate = [[RTCICECandidate alloc] initWithMid:[dic valueForKey:SDP_MID]
//                                                                    index:(int)[dic valueForKey:SDP_MLINE_INDEX]
//                                                                      sdp:[dic valueForKey:CANDIDATE_SDP]];
//
//
//        [self.peerConn addICECandidate:candidate];
//    }
//}

//-(void)prepareConnectionPeer:(NSString*) sdp
//{
//    [RTCPeerConnectionFactory initializeSSL];
//
//    self.factory = [[RTCPeerConnectionFactory alloc] init];
//
//    RTCICEServer *iceServer = [[RTCICEServer alloc] initWithURI:[[NSURL alloc] initWithString:@"stun:stun.l.google.com:19302"] username:@"" password:@""];
//
//    NSArray *iceServerArray = [[NSArray alloc] initWithObjects:iceServer, nil];
//
//    self.peerConn = [self.factory peerConnectionWithICEServers:iceServerArray constraints:nil delegate:self];
//
//    RTCMediaStream* localStream = [self.factory mediaStreamWithLabel:[[NSUUID UUID] UUIDString]];
//
//    RTCAudioTrack* audioTarck = [self.factory audioTrackWithID:[[NSUUID UUID] UUIDString]];
//
//    [localStream addAudioTrack:audioTarck];
//
//    [self.peerConn addStream:localStream];
//
//}


//-(void) createOffer
//{
//
//    NSArray *mandConst = [[NSArray alloc] initWithObjects:[[RTCPair alloc] initWithKey:@"OfferToReceiveAudio" value:@"true"], nil ];
//
//    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandConst optionalConstraints:nil];
//
//    [peerConn createOfferWithDelegate:self constraints:constraints];
//
//    NSLog(@"Offer created");
//}

//-(void)handleIncomingAnswer:(NSString* )sdp
//{
//
//    RTCSessionDescription *remoteDesc = [[RTCSessionDescription alloc] initWithType:@"answer" sdp:sdp];
//
//    [self.peerConn setRemoteDescriptionWithDelegate:self sessionDescription:remoteDesc];
//
//   // [self setCandidates];
//
//}
//
//-(void)handleIncomingOffer:(NSString* )sdp
//{
//
//    RTCSessionDescription *remoteDesc = [[RTCSessionDescription alloc] initWithType:@"offer" sdp:sdp];
//
//    [self.peerConn setRemoteDescriptionWithDelegate:self sessionDescription:remoteDesc];
//
//
//
//}



-(void)viewWillAppear:(BOOL)animated
{
//    AVAudioSessionPortOverride override = AVAudioSessionPortOverrideSpeaker;
//    [RTCDispatcher dispatchAsyncOnType:RTCDispatcherTypeAudioSession
//                                 block:^{
//                                     RTCAudioSession *session =     [RTCAudioSession sharedInstance];
//                                     [session lockForConfiguration];
//                                     NSError *error = nil;
//                                     if ([session overrideOutputAudioPort:override error:&error]) {
//                                         _portOverride = override;
//                                     } else {
//                                         RTCLogError(@"Error overriding output port: %@",
//                                                     error.localizedDescription);
//                                     }
//                                     [session unlockForConfiguration];
//                                 }];
//    self.tlk = [[WebRTC alloc] init];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self.tlk
//                                             selector:@selector(setSDPGotFromServer:) name:NOTIFICATION_GET_SDP
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self.tlk
//                                             selector:@selector(setCandidatesGotFromServer:) name:NOTIFICATION_GET_CANDIDATES
//                                               object:nil];
//    
//    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
//    {
//        
//        [self.tlk addPeerConnectionForID:@"iPad"];
//
//    }
//    else
//    {
//        [self.tlk addPeerConnectionForID:@"iPhone"];
//
//        
//    }
//   
}

//-(void)peerConnection:(RTCPeerConnection *)peerConnection addedStream:(RTCMediaStream *)stream
//{
//    NSLog(@"added");
////    NSURL* url =  [stream.audioTracks.lastObject absoluteURL];
////    NSData *data = [NSData dataWithContentsOfURL:url];
////    _audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:nil];
////    [_audioPlayer play];
//
//    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
//    {
//       NSLog(@"receive on ipad"); /* Device is iPad */
//    }
//    else
//    {
//     NSLog(@"receive on iphone");
//    }
//
//    //RTCEAGLVideoView *renderView = [[RTCEAGLVideoView alloc] initWithFrame:CGRectMake(0,0,100, 100)];
//
//
//   // [stream.audioTracks.lastObject addRenderer:renderView];
//
//
//
//
//}
//- (void)peerConnectionOnError:(RTCPeerConnection *)peerConnection
//{
//    //    dispatch_async(dispatch_get_main_queue(), ^{
//    //    });
//    NSLog(@"Error = %@",peerConnection);
//}
//
//
//-(void)peerConnection:(RTCPeerConnection *)peerConnection didOpenDataChannel:(RTCDataChannel *)dataChannel
//{
//
//}
//-(void)peerConnection:(RTCPeerConnection *)peerConnection removedStream:(RTCMediaStream *)stream
//{
//
//}
//
//-(void)peerConnection:(RTCPeerConnection *)peerConnection gotICECandidate:(RTCICECandidate *)candidate
//{
//
//    //[peerConnection addICECandidate:candidate];
//    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
//    {
//        NSLog(@"Got ICE Candidate in iPad");
//    }
//    else
//    {
//        NSLog(@"Got ICE Candidate in iPhone");
//    }
//
//    [iceCandidateArray addObject:candidate];
//
//    NSMutableDictionary* dict = [NSMutableDictionary new];
//
//    [dict setValue:candidate.sdpMid forKey:SDP_MID];
//    [dict setValue:[NSString stringWithFormat:@"%ld",(long)candidate.sdpMLineIndex] forKey:SDP_MLINE_INDEX];
//    [dict setValue:candidate.sdp forKey:CANDIDATE_SDP];
//
//    [iceCandidateDictArray addObject:dict];
//}
//
//
//-(void)peerConnection:(RTCPeerConnection *)peerConnection iceGatheringChanged:(RTCICEGatheringState)newState
//{
//
//    if (newState == RTCICEGatheringComplete)
//    {
////        dispatch_async(dispatch_get_main_queue(), ^{
////            [self performSelector:@selector(sendCAndidatesToServer) withObject:nil afterDelay:6.0];
////        });
//        for (int i= 0; i<iceCandidateArray.count; i++)
//        {
//
//            [self.peerConn addICECandidate:(RTCICECandidate*)iceCandidateArray[i]];
//        }
//
//        [self sendCAndidatesToServer];
//
//    }
//}
//
//
//-(void) sendCAndidatesToServer
//{
//
//
//    if (iceCandidateArray.count > 0)
//    {
//
//        NSError *error;
//        NSString* json, *json1;
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:iceCandidateDictArray options:NSJSONWritingPrettyPrinted error:&error];
//
//        if (! jsonData) {
//
//        } else {
//            json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        }
//
//        NSMutableDictionary* dict = [NSMutableDictionary new];
//
//        [dict setValue:json forKey:@"dict"];
//
//        NSData *jsonData1 = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
//
//        if (! jsonData1) {
//            return;
//        } else {
//            json1 = [[NSString alloc] initWithData:jsonData1 encoding:NSUTF8StringEncoding];
//        }
//        [[APIManager sharedManager] sendCandidateUsername:self.usernameTextFIeld.text candidate:json1];
//
//    }
//
//}
//-(void)peerConnection:(RTCPeerConnection *)peerConnection iceConnectionChanged:(RTCICEConnectionState)newState
//{
//
//    NSLog(@"Connection state: %u", newState);
//}
//
//-(void)peerConnectionOnRenegotiationNeeded:(RTCPeerConnection *)peerConnection
//{
//    NSLog(@"peerConnectionOnRenegotiationNeeded");
//}
//
//
//-(void)peerConnection:(RTCPeerConnection *)peerConnection signalingStateChanged:(RTCSignalingState)stateChanged
//{
//    NSLog(@"Signalling state: %u", stateChanged);
//}
//
//-(void)peerConnection:(RTCPeerConnection *)peerConnection didCreateSessionDescription:(RTCSessionDescription *)sdp error:(NSError *)error
//{
//    self.SDP = [NSString stringWithFormat:@"%@",sdp];
//
//    [peerConnection setLocalDescriptionWithDelegate:self sessionDescription:sdp];
//
//
//}
//
//-(void)peerConnection:(RTCPeerConnection *)peerConnection didSetSessionDescriptionWithError:(NSError *)error
//{
//    if (peerConnection.signalingState == RTCSignalingHaveLocalOffer)
//    {
//        // send sdp of offer and then for answer
//
//        [AppPreferences sharedAppPreferences]. isCalled = true;
//
////        [[APIManager sharedManager] sendSDPUsername:self.usernameTextFIeld.text SDP:self.SDP];
//        //[self sendCAndidatesToServer];
//
//        [self sendSDP:peerConnection];
//
////        if (peerConnection.signalingState == RTCSignalingStable && [AppPreferences sharedAppPreferences]. isCalled == false)
////        [self sendCAndidatesToServer];
//       // dispatch_async(dispatch_get_main_queue(), ^{
//            // [self performSelector:@selector(sendSDP) withObject:nil afterDelay:6.0];
//
//       // });
////        if (iceCandidateGotFromServerArray.count > 0)
////        {
////            [self setCandidates];
////        }
//    }
//    else
//    if(peerConnection.signalingState == RTCSignalingHaveRemoteOffer)
//    {
//        // [self setCandidates];
//
//        NSArray *mandConst = [[NSArray alloc] initWithObjects:[[RTCPair alloc] initWithKey:@"OfferToReceiveAudio" value:@"true"], nil ];
//
////        RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandConst optionalConstraints:nil];
//
//        RTCMediaConstraints *constraints = [self _mediaConstraints];
//
//        [peerConnection createAnswerWithDelegate:self constraints:constraints];
//
//       // [self sendCAndidatesToServer];
//
//    }
//    else
//        if (peerConnection.signalingState == RTCSignalingStable)
//        {
//            if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
//            {
//
//                [self sendSDP:peerConnection];
//            }
//        }
//}
//
//- (RTCMediaConstraints *)_mediaConstraints
//{
//    RTCPair *audioConstraint = [[RTCPair alloc] initWithKey:@"OfferToReceiveAudio" value:@"true"];
//    RTCPair *videoConstraint = [[RTCPair alloc] initWithKey:@"OfferToReceiveVideo" value:@"false"];
//    RTCPair *sctpConstraint = [[RTCPair alloc] initWithKey:@"internalSctpDataChannels" value:@"true"];
//    RTCPair *dtlsConstraint = [[RTCPair alloc] initWithKey:@"DtlsSrtpKeyAgreement" value:@"true"];
//
//    return [[RTCMediaConstraints alloc] initWithMandatoryConstraints:@[audioConstraint, videoConstraint] optionalConstraints:@[sctpConstraint, dtlsConstraint]];
//}
//
//-(void) sendSDP: (RTCPeerConnection*) peerConnection
//{
//    [[APIManager sharedManager] sendSDPUsername:self.usernameTextFIeld.text SDP:peerConnection.localDescription];
//}



//- (IBAction)createOfferClicked:(id)sender
//{
//    [self createOffer];
//}

- (IBAction)commonSetupButtonClicked:(id)sender
{
//     self.tlk = [[TLKWebRTC alloc] init];
//
//     self.tlk.delegate = self;
//
//    [[NSNotificationCenter defaultCenter] addObserver:self.tlk
//                                             selector:@selector(setSDPGotFromServer:) name:NOTIFICATION_GET_SDP
//                                               object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self.tlk
//                                             selector:@selector(setCandidatesGotFromServer:) name:NOTIFICATION_GET_CANDIDATES
//                                               object:nil];
//
//
//    [self.tlk addPeerConnectionForID:@"iPad" iceServerArray:self.serverCredArray];
}

- (IBAction)initOfferButtonClicked:(id)sender
{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        [self.audioCallButton setHidden:true];
        
        self.tlk = [[TLKWebRTC alloc] init];
        
        self.tlk.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self.tlk
                                                 selector:@selector(setSDPGotFromServer:) name:NOTIFICATION_GET_SDP
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self.tlk
                                                 selector:@selector(setCandidatesGotFromServer:) name:NOTIFICATION_GET_CANDIDATES
                                                   object:nil];
        
        
        [self.tlk addPeerConnectionForID:@"iPad" iceServerArray:self.serverCredArray];
    }
    else
    {
        self.tlk = [[TLKWebRTC alloc] init];
        
        self.tlk.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self.tlk
                                                 selector:@selector(setSDPGotFromServer:) name:NOTIFICATION_GET_SDP
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self.tlk
                                                 selector:@selector(setCandidatesGotFromServer:) name:NOTIFICATION_GET_CANDIDATES
                                                   object:nil];
        
        
        [self.tlk addPeerConnectionForID:@"iPhone" iceServerArray:self.serverCredArray];
        
        // [self.tlk initDataChannel:@"iPhone"];
        
        [self.tlk createOfferForPeerWithID:@"iPhone"];
        
        self.callStatusLabel.hidden = NO;
        
        self.callStatusLabel.text = @"Connecting..";
    }
   
    
}

-(void) setICEServersGotFromXIR:(NSNotification *)notification
{
    NSDictionary* dic = notification.object;
    
    NSDictionary* vDict = [dic objectForKey:@"v"];
    
    NSArray* iceServersDict = [vDict valueForKey:@"iceServers"];
    
    self.serverCredArray = [NSMutableArray new];
    
    for (NSDictionary* serverCredDict in iceServersDict)
    {
        //        NSString* url = [serverCredDict valueForKey:@"url"];
        //        NSString* username = [serverCredDict valueForKey:@"username"];
        //        NSString* credential = [serverCredDict valueForKey:@"credential"];
        
        [self.serverCredArray addObject:serverCredDict];
    }
}
//- (IBAction)registerButtonClicked:(id)sender
//{
//     [[APIManager sharedManager] updateDevieTokenUsername:self.usernameTextFIeld.text andDeviceId:[AppPreferences sharedAppPreferences].deviceToken];
//}
//- (IBAction)initPeerButtonClicked:(id)sender
//{
//    [self prepareConnectionPeer:@""];
//}
//
//- (IBAction)sendMessageButtonClicked:(id)sender
//{
//    [self.tlk sendDataToRemote:@"hello" peerId:@"iPhone"];
//}


//- (IBAction)socketWriteButtonClicked:(id)sender
//{
//    // [self.socket writeString:@"Hi server"];
//    //[self.socket ]
//}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//-(void) createSocketConnection
//{
//    self.socket = [[JFRWebSocket alloc] initWithURL:[NSURL URLWithString:@"ws://192.168.3.75:8080"] protocols:@[@"chat",@"superchat",@"echo-protocol"]];
//
//    self.socket.delegate = self;
//
//    [self.socket connect];
//
//
//}
//
//-(void)websocketDidConnect:(JFRWebSocket*)socket
//{
//    NSLog(@"websocket is connected");
//}
//-(void)websocket:(JFRWebSocket*)socket didReceiveMessage:(NSString*)string
//{
//    NSLog(@"got some text: %@",string);
//    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
//    NSDictionary* jsonOutput = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//    NSString* sdp = jsonOutput[@"sdp"];
//    NSString* user = jsonOutput[@"user"];
//
//    if ([user  isEqual: @"1"])
//    {
//
//    }
//    else
//    {
//        [self handleIncomingAnswer:sdp];
//    }
//    NSLog(@"%@",jsonOutput);
//}
//-(void)websocket:(JFRWebSocket*)socket didReceiveData:(NSData*)data
//{
//    NSLog(@"got some binary data: %@",data);
////    NSString* json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
////    NSLog(@"%@", [NSString stringWithFormat:@"json = %@",json]);
//   // [self handleIncomingAnswer:[NSString stringWithFormat:@"%@",data]];
//    //NSString* string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//    //NSLog(@"op = %@",string);
//}

- (IBAction)resetButtonClicked:(id)sender
{
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
    
            [self.tlk removePeerConnectionForID:@"iPad"];
            self.tlk = nil;
        }
        else
        {
            [self.tlk removePeerConnectionForID:@"iPhone"];
            self.tlk = nil;

        }
}

-(void)webRTC:(TLKWebRTC*)tlk didSendSDPOffer:(RTCSessionDescription*)localDescription forPeerWithID:(NSString*)peerId
{
    [[APIManager sharedManager] sendSDPUsername:peerId SDP:localDescription];

}

-(void)webRTC:(TLKWebRTC*)tlk didSendSDPAnswer:(RTCSessionDescription*)localDescription forPeerWithID:(NSString*)peerId
{
    [[APIManager sharedManager] sendSDPUsername:peerId SDP:localDescription];

}

- (void)webRTC:(TLKWebRTC *)webRTC didSendICECandidate:(RTCICECandidate *)candidate forPeerWithID:(NSString *)peerID
{
    NSMutableArray* iceCandidateArray = [NSMutableArray new];
    NSMutableArray* iceCandidateDictArray = [NSMutableArray new];
    
    [iceCandidateArray addObject:candidate];
    
    NSMutableDictionary* dict = [NSMutableDictionary new];
    
    [dict setValue:candidate.sdpMid forKey:SDP_MID];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)candidate.sdpMLineIndex] forKey:SDP_MLINE_INDEX];
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

- (void)webRTC:(TLKWebRTC *)webRTC didObserveICEConnectionStateChange:(RTCICEConnectionState)state forPeerWithID:(NSString *)peerID
{
    if (state == 2)
    {
        self.callStatusLabel.hidden = NO;
        
        self.callStatusLabel.text = @"Connected";
        
        
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

-(void) sendCandidateToServer:(NSDictionary*)dic
{
    
//    RTCPeerConnection* peerConnection = [dic objectForKey:@"connection"];
//    RTCICECandidate* candidate = [dic objectForKey:@"candidate"];
//    NSArray* keys = [self.peerConnections allKeysForObject:peerConnection];
//    if ([keys count] > 0)
//    {
    
        //  [self.delegate webRTC:self didSendICECandidate:candidate forPeerWithID:keys[0]];
        
        
        
        
        
        
//        NSMutableArray* iceCandidateArray = [NSMutableArray new];
//        NSMutableArray* iceCandidateDictArray = [NSMutableArray new];
//        
//        [iceCandidateArray addObject:candidate];
//        
//        NSMutableDictionary* dict = [NSMutableDictionary new];
//        
//        [dict setValue:candidate.sdpMid forKey:SDP_MID];
//        [dict setValue:[NSString stringWithFormat:@"%ld",(long)candidate.sdpMLineIndex] forKey:SDP_MLINE_INDEX];
//        [dict setValue:candidate.sdp forKey:CANDIDATE_SDP];
//        
//        [iceCandidateDictArray addObject:dict];
//        
//        
//        NSError *error;
//        NSString* json, *json1;
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:iceCandidateDictArray options:NSJSONWritingPrettyPrinted error:&error];
//        
//        if (! jsonData) {
//            
//        } else {
//            json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        }
//        
//        NSMutableDictionary* dict1 = [NSMutableDictionary new];
//        
//        [dict1 setValue:json forKey:@"dict"];
//        
//        NSData *jsonData1 = [NSJSONSerialization dataWithJSONObject:dict1 options:NSJSONWritingPrettyPrinted error:&error];
//        
//        if (! jsonData1) {
//            return;
//        } else {
//            json1 = [[NSString alloc] initWithData:jsonData1 encoding:NSUTF8StringEncoding];
//        }
//        [[APIManager sharedManager] sendCandidateUsername:keys[0] candidate:json1];
//        
        
//    }
    
}
@end
