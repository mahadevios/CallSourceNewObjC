
//stable

//
//  TLKWebRTC.m
//  Copyright (c) 2014 &yet, LLC and TLKWebRTC contributors
//
//webrtc steps https://stackoverflow.com/questions/37672080/webrtc-integration-in-ios-with-own-server
//https://www.codeproject.com/Articles/1073738/Building-a-Video-Chat-Web-App-with-WebRTC
//https://shanetully.com/2014/09/a-dead-simple-webrtc-example/
// https://webrtc.github.io/samples/src/content/peerconnection/trickle-ice/ check for valid stun/turn server
// https://tools.ietf.org/html/rfc5766 // turn server details

// https://voipmagazine.wordpress.com/tag/server-reflexive-address/  // tuen working details

// https://webrtchacks.com/sdp-anatomy/  sdp offer content details meaning

// https://tech.appear.in/2015/05/25/Getting-started-with-WebRTC-on-iOS/  basic tutorial


// https://tools.ietf.org/id/draft-ietf-behave-turn-08.html#sec-sendanddata  relayed addrs and server refl. addrs binding mechanism and TURN server esplanation

//https://xirsys.com/terms/

// MultipeerConnectivity


// https://groups.google.com/forum/#!msg/kurento/wN4wM4NIMI4/xjEs1KwmOw0J  kurrento group link

// https://tools.ietf.org/html/draft-ietf-mmusic-trickle-ice-02 // add trickle support

// https://www.webrtc-experiment.com/docs/how-to-WebRTC-video-conferencing.html  multi user offer answer

// https://webrtchacks.com/limit-webrtc-bandwidth-sdp/  update sdp
#import "TLKWebRTC.h"

#import <AVFoundation/AVFoundation.h>


#import "NSString+URLEncodedString.h"

#import "AppDelegate.h"

#import "ReigisteredUsersViewController.h"

@interface TLKWebRTC () <RTCPeerConnectionDelegate,RTCDataChannelDelegate,RTCVideoCapturerDelegate>



@end

static NSString * const TLKPeerConnectionRoleInitiator = @"TLKPeerConnectionRoleInitiator";
static NSString * const TLKPeerConnectionRoleReceiver = @"TLKPeerConnectionRoleReceiver";
static NSString * const TLKWebRTCSTUNHostname1 = @"stun:stun.l.google.com:19302";
static NSString * const TLKWebRTCSTUNHostname2 = @"turn:66.228.45.110:3478";
//static NSString * const TLKWebRTCSTUNHostname3 = @"turn:m2.xirsys.com:80?transport=udp";
//static NSString * const TLKWebRTCSTUNHostname2 = @"turn:s2.xirsys.com:3478?transport=udp";


@implementation TLKWebRTC

#pragma mark - object lifecycle

- (instancetype)initWithVideoDevice:(AVCaptureDevice *)device
{
    self = [super init];
    if (self)
    {
        if (device)
        {
            _allowVideo = YES;
            _videoDevice = device;
        }
        [self _commonSetup];
    }
    return self;
}

- (instancetype)initWithVideo:(BOOL)allowVideo
{
    // Set front camera as the default device
    AVCaptureDevice* frontCamera;
    if (allowVideo)
    {
        frontCamera = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] lastObject];
    }
    return [self initWithVideoDevice:frontCamera];
}

- (instancetype)init
{
    // Use default device
    
    //self.cachedCandidateToSendArray = [NSMutableArray new];
    
    return [self initWithVideo:YES];
}

#pragma mark - Create Local Stream(to add later to peer connection)

- (void)_commonSetup
{
    _peerFactory = [[RTCPeerConnectionFactory alloc] init];
    
    _peerConnections = [NSMutableDictionary dictionary];
    
    _peerToRoleMap = [NSMutableDictionary dictionary];
    
    _peerToICEMap = [NSMutableDictionary dictionary];
    
    self.iceServers = [NSMutableArray new];
    
    self.iceCandidateDictArray = [NSMutableArray new];
    
    //    RTCICEServer *defaultStunServer = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:TLKWebRTCSTUNHostname1] username:@"" password:@""];
    
    //    RTCICEServers *defaultTurnServer = [[RTCICEServers alloc] initWithURI:[NSURL URLWithString:TLKWebRTCSTUNHostname2] username:@"mahadevmandale@yahoo.com" password:@"Mahadev7"];
    
    NSMutableArray* stunTurnUrlStringArray = [[NSMutableArray alloc] initWithObjects:TLKWebRTCSTUNHostname1,TLKWebRTCSTUNHostname2, nil];
    
    RTCIceServer *defaultTurnServer = [[RTCIceServer alloc] initWithURLStrings:stunTurnUrlStringArray username:@"mahadevmandale@yahoo.com" credential:@"Mahadev7"];
    
    [self addICEServer:defaultTurnServer];
    
    [RTCPeerConnectionFactory initialize];
    
    [self _createLocalStream];
}

- (void)_createLocalStream
{
    self.localMediaStream = [self.peerFactory mediaStreamWithStreamId:[[NSUUID UUID] UUIDString]];
    
    RTCAudioTrack *audioTrack = [self.peerFactory audioTrackWithTrackId:[[NSUUID UUID] UUIDString]];
    
    [self.localMediaStream addAudioTrack:audioTrack];
    
    if (self.allowVideo)
    {
//                RTCAVFoundationVideoSource *videoSource = [[RTCAVFoundationVideoSource alloc] initWithFactory:self.peerFactory constraints:nil];
//
//                videoSource.useBackCamera = NO;
//
//                RTCVideoTrack *videoTrack = [[RTCVideoTrack alloc] initWithFactory:self.peerFactory source:videoSource trackId:[[NSUUID UUID] UUIDString]];
//
//                [self.localMediaStream addVideoTrack:videoTrack];
        // Find the device that is the front facing camera
        AVCaptureDevice *device;
        for (AVCaptureDevice *captureDevice in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] ) {
            if (captureDevice.position == AVCaptureDevicePositionFront) {
                device = captureDevice;
                break;
            }
        }
        
        // Create a video track and add it to the media stream
        if (device) {
//            RTCVideoSource *videoSource;
            
            self.videoSource = [self.peerFactory videoSource];
//            RTCVideoCapturer *capturer = [RTCVideoCapturer capturerWithDeviceName:device.localizedName];
//            RTCVideoCapturer *capturer = [[RTCVideoCapturer alloc] initWithDelegate:self];

            self.capt = [[RTCCameraVideoCapturer alloc] initWithDelegate:self];
            
        
            [self.capt startCaptureWithDevice:device format:device.formats[0] fps:10];
//            self.peerFactory video
            
//            videoSource = [self.peerFactory videoSourceWithCapturer:capturer constraints:nil];
            self.videoTrack = [self.peerFactory videoTrackWithSource:self.videoSource trackId:[[NSUUID UUID] UUIDString]];
            
//            self.renderView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 100, 100)];
//            
//           ReigisteredUsersViewController* vc =  [[UIApplication sharedApplication].keyWindow rootViewController];
//            
//            [self.videoTrack addRenderer:self.renderView];
//            
//            [vc.view addSubview:self.renderView];
            
            [self.localMediaStream addVideoTrack:self.videoTrack];
        }
    }
}

- (void)capturer:(RTCVideoCapturer *)capturer didCaptureVideoFrame:(RTCVideoFrame *)frame
{
    [self.videoSource capturer:capturer didCaptureVideoFrame:frame];
}
- (RTCMediaConstraints *)_mediaConstraints
{
    
    
    NSDictionary* mandateConstraint = [[NSDictionary alloc] initWithObjectsAndKeys:kRTCMediaConstraintsValueTrue,kRTCMediaConstraintsOfferToReceiveAudio,self.allowVideo ? kRTCMediaConstraintsValueTrue : kRTCMediaConstraintsValueFalse, @"OfferToReceiveVideo", nil];
    
    NSDictionary* optionalConstraint = [[NSDictionary alloc] initWithObjectsAndKeys:kRTCMediaConstraintsValueTrue,@"DtlsSrtpKeyAgreement", kRTCMediaConstraintsValueTrue,@"internalSctpDataChannels",  nil];
    
    return [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandateConstraint optionalConstraints:optionalConstraint];
}


- (void)addICEServer:(RTCIceServer *)server
{
    BOOL isStun = [server.hostname containsString:@"stun"];
    if (isStun)
    {
        // Array of servers is always stored with stun server in first index, and we only want one,
        // so if this is a stun server, replace it
        [self.iceServers replaceObjectAtIndex:0 withObject:server];
    }
    else
    {
        [self.iceServers addObject:server];
    }
}

#pragma mark - Remote Notifications

-(void) setSDPGotFromServer:(NSNotification *)notification
{
    // modify the SDP if corrupted (if involves space instead of +)
    NSDictionary* dic = notification.object;
    
    NSString* sdpType = [dic valueForKey:@"sdpType"];

    NSString* sdpSender = [dic valueForKey:@"sdpSender"];
    
    self.sdpSender = sdpSender;
    
    NSDictionary* apsDict = [dic objectForKey:@"aps"];
    
//    [apsDict valueForKey:@"alert"];
    
    NSString* sdp = [apsDict valueForKey:@"alert"];
    
    NSRange uFragTagRange = [sdp rangeOfString:@"a=ice-ufrag:"];
    
    NSRange pwdTagRange = [sdp rangeOfString:@"a=ice-pwd:"];
    
    NSRange fingerPringTagRange = [sdp rangeOfString:@"a=fingerprint:"];

    int ufragTotalLength = pwdTagRange.location-uFragTagRange.location-1;
  
    NSRange uFragRange = NSMakeRange(uFragTagRange.location, ufragTotalLength);
    
    NSString* uFragTotalSubString = [sdp substringWithRange:uFragRange];

    NSString* ufragReplaceString = [uFragTotalSubString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    sdp = [sdp stringByReplacingCharactersInRange:uFragRange withString:ufragReplaceString];
    
    int pwdTotalLength = fingerPringTagRange.location-pwdTagRange.location-1;
    
    NSRange pwdRange = NSMakeRange(pwdTagRange.location, pwdTotalLength);
    
    NSString* pwdTotalSubString = [sdp substringWithRange:pwdRange];
    
    NSString* replacepwdString = [pwdTotalSubString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    sdp = [sdp stringByReplacingCharactersInRange:pwdRange withString:replacepwdString];
    
    NSMutableString *sdp1 = [NSMutableString stringWithString:sdp];

    NSLog(@"Got new SDP from Noti.= %@", sdp1);
    
    NSString* loggedInUser = [[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_USER];
    
    if ([sdpType isEqualToString:@"offer"] )
    {
        RTCSessionDescription *remoteDesc = [[RTCSessionDescription alloc] initWithType:RTCSdpTypeOffer sdp:sdp1];
        
//          dispatch_async(dispatch_get_main_queue(), ^{
        
        [self setRemoteDescription:remoteDesc forPeerWithID:loggedInUser receiver:true];
//         });
    }
    else
    {
        RTCSessionDescription *remoteDesc = [[RTCSessionDescription alloc] initWithType:RTCSdpTypeAnswer sdp:sdp1];
        
//            dispatch_async(dispatch_get_main_queue(), ^{
        
                [self setRemoteDescription:remoteDesc forPeerWithID:loggedInUser receiver:false];

        
//            });
        
    }

}


-(void) setCandidatesGotFromServer:(NSNotification *)notification
{

    NSDictionary* dic = notification.object;
    
    NSDictionary* apsDict = [dic objectForKey:@"aps"];
    
    [apsDict valueForKey:@"alert"];
    
    NSString* candidates =[apsDict valueForKey:@"alert"];
    
    NSData *data1 = [candidates dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError* err;
    
    self.iceCandidateGotFromServerArray = [NSMutableArray new];
    
    self.iceCandidateGotFromServerArray = [NSJSONSerialization JSONObjectWithData:data1 options:NSJSONReadingAllowFragments error:&err];
    
    
//    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
//    {
    
        for (int i = 0; i< self.iceCandidateGotFromServerArray.count; i++)
        {
            NSDictionary* dic = self.iceCandidateGotFromServerArray[i];
            
            NSString* sdp = [dic objectForKey:CANDIDATE_SDP];
            
//            NSRange uFragTagRange = [sdp rangeOfString:@"ufrag "];
//
//            NSRange sdpRange = [sdp rangeOfString:sdp];
//
//            int sdpWOufragLength = uFragTagRange.location;
//
//            int ufragTotalLength = sdpRange.length - sdpWOufragLength;
//
//            NSRange uFragRange = NSMakeRange(uFragTagRange.location+6, ufragTotalLength-6);
//
//            NSString* uFragTotalSubString = [sdp substringWithRange:uFragRange];
//
//            NSString* ufragReplaceString = [uFragTotalSubString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
//
//            sdp = [sdp stringByReplacingCharactersInRange:uFragRange withString:ufragReplaceString];

            int index = [[dic objectForKey:SDP_MLINE_INDEX] intValue];
            
//            RTCIceCandidate *candidate = [[RTCIceCandidate alloc] initWithMid:[dic objectForKey:SDP_MID]
//                                                                        index:ind
//                                                                          sdp:sdp];

            NSString* sdpMid = [dic objectForKey:SDP_MID];
            
            RTCIceCandidate *candidate = [[RTCIceCandidate alloc] initWithSdp:sdp sdpMLineIndex:index sdpMid:sdpMid];
            //
            
//            NSLog(@"Got new Canidate from Noti. =%@", candidate);
            
            NSString* loggedInUser  = [[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_USER];
            
            [self addICECandidate:candidate forPeerWithID:loggedInUser];
            
        }
//    }
//    else
//    {
//        for (int i = 0; i< self.iceCandidateGotFromServerArray.count; i++)
//        {
//            NSDictionary* dic = self.iceCandidateGotFromServerArray[i];
//
//            NSString* sdp = [dic objectForKey:CANDIDATE_SDP];
//
//            NSRange uFragTagRange = [sdp rangeOfString:@"ufrag "];
//
//            NSRange sdpRange = [sdp rangeOfString:sdp];
//
//            int sdpWOufragLength = uFragTagRange.location;
//
//            int ufragTotalLength = sdpRange.length - sdpWOufragLength;
//
//            NSRange uFragRange = NSMakeRange(uFragTagRange.location+6, ufragTotalLength-6);
//
//            NSString* uFragTotalSubString = [sdp substringWithRange:uFragRange];
//
//            NSString* ufragReplaceString = [uFragTotalSubString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
//
//            sdp = [sdp stringByReplacingCharactersInRange:uFragRange withString:ufragReplaceString];
//
//            RTCICECandidate *candidate = [[RTCICECandidate alloc] initWithMid:[dic objectForKey:SDP_MID]
//                                                                        index:0
//                                                                          sdp:sdp];
//
////            NSLog(@"Got new Canidate from Noti. =%@", candidate);
//
//            [self addICECandidate:candidate forPeerWithID:@"iPhone"];
//
//        }
//
//    }
    
}

- (void)setRemoteDescription:(RTCSessionDescription *)remoteSDP forPeerWithID:(NSString *)peerID receiver:(BOOL)isReceiver
{
    RTCPeerConnection *peerConnection = [self.peerConnections objectForKey:peerID];
    
    //RTCDataChannel* c = [peerConnection dataChannelForLabel:@"" configuration:nil];
    
    
    //    __weak RTCPeerConnection *peerConnection1 = peerConnection;
    
    if (isReceiver)
    {
        [self.peerToRoleMap setObject:TLKPeerConnectionRoleReceiver forKey:peerID];
    }
    
    
    [peerConnection setRemoteDescription:remoteSDP completionHandler:^(NSError * _Nullable error)
     {
         
         if (peerConnection.signalingState == RTCSignalingStateHaveRemoteOffer)
         {
             //            NSLog(@"media const = %@", [self  _mediaConstraints]);
             
             
             [peerConnection answerForConstraints:[self _mediaConstraints] completionHandler:^(RTCSessionDescription * _Nullable sdp1, NSError * _Nullable error) {
                 
                 [peerConnection setLocalDescription:sdp1 completionHandler:^(NSError * _Nullable error) {
                     NSArray* keys = [self.peerConnections allKeysForObject:peerConnection];
                     
                     NSString* role = [self.peerToRoleMap objectForKey:keys[0]];
                     
                     
                     if (role == TLKPeerConnectionRoleReceiver)
                     {
                         [self.delegate webRTC:self didSendSDPAnswer:sdp1.sdp forPeerWithID:keys[0] calleeUser:self.sdpSender allowVideo:[NSString stringWithFormat:@"%d",self.allowVideo]];
                     }
                 }];
                 
                 //                }
                 
                 
             }];
         }
         else
             if (peerConnection.signalingState == RTCSignalingStateStable)
             {
                 
             }
         
         
     }];
    
    
}

- (void)addICECandidate:(RTCIceCandidate*)candidate forPeerWithID:(NSString *)peerID
{
    RTCPeerConnection *peerConnection = [self.peerConnections objectForKey:peerID];
    
    //    if (peerConnection.iceGatheringState == RTCICEGatheringNew)
    //    {
    //        NSMutableArray *candidates = [self.peerToICEMap objectForKey:peerID];
    //
    //        if (!candidates)
    //        {
    //            candidates = [NSMutableArray array];
    //
    //            [self.peerToICEMap setObject:candidates forKey:peerID];
    //        }
    //
    //        [candidates addObject:candidate];
    //
    //        NSLog(@"candidate added to stack from Noti");
    //    }
    //    else
    //    {
    if (peerConnection.remoteDescription == nil)
    {
        NSLog(@"my candidate noti.");

        [self.iceCandidateDictArray addObject:candidate];
    }
    else
    {
        for (RTCIceCandidate* candidate in self.iceCandidateDictArray)
        {
            [peerConnection addIceCandidate:candidate];
            
            //[[RTCPeerConnection alloc] addICECandidate:candidate];
            NSLog(@"Remote candidate = %@", candidate);
        }
        
        [self.iceCandidateDictArray removeAllObjects];
        
        NSLog(@"Remote candidate = %@", candidate);
        
        [peerConnection addIceCandidate:candidate];
        
        
        // NSLog(@"candidate added directly from Noti = %d",added);
        
        NSLog(@"remote desc after adding candidate = %@",peerConnection.remoteDescription);
        //NSLog(@"remote desc after cand. addn = %@", peerConnection.remoteDescription.description) ;
    }
    
    
    
    //    }
}

//#pragma mark - ICE server

#pragma mark - Peer Connections Create and Maintain


- (void)addPeerConnectionForID:(NSString *)identifier iceServerArray:(NSMutableArray*)iceServerArray;
{
    self.XIRiceServerArray = iceServerArray;
    
    
//    for (NSDictionary* serverCredDict in self.XIRiceServerArray)
//    {
//        NSString* url = [serverCredDict valueForKey:@"url"];
//        NSString* username = [serverCredDict valueForKey:@"username"];
//        NSString* credential = [serverCredDict valueForKey:@"credential"];
//
//        if (username == nil)
//        {
//            username = @"";
//        }
//        if (credential == nil)
//        {
//            credential = @"";
//        }
//        RTCICEServer *defaultTurnServer = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:url] username:username password:credential];
//
//
//        [self.iceServers addObject:defaultTurnServer];
//    }
    
//    RTCPeerConnection *peer = [self.peerFactory peerConnectionWithICEServers:[self iceServers] constraints:[self _mediaConstraints] delegate:self];
//    self.peerFactory

    //[self.peerFactory connection]
    RTCConfiguration* conf = [[RTCConfiguration alloc] init];
    
    conf.iceServers = [self iceServers];

//    conf.iceTransportPolicy = RTCIceTransportPolicyAll;
//
//    conf.bundlePolicy = RTCBundlePolicyBalanced;
//
//    conf.rtcpMuxPolicy = RTCRtcpMuxPolicyNegotiate;
//
//    conf.tcpCandidatePolicy = RTCTcpCandidatePolicyEnabled;
//
//    conf.audioJitterBufferMaxPackets = 50;
//
//    conf.iceConnectionReceivingTimeout = 1;
//
//    conf.iceBackupCandidatePairPingInterval = 1;

    RTCPeerConnection *peer = [self.peerFactory peerConnectionWithConfiguration:conf constraints:[self _mediaConstraints] delegate:self];

    [peer addStream:self.localMediaStream];
    
//    RTCConfiguration *conf1 = [[RTCConfiguration alloc] init];
//
//    conf1.iceConnectionReceivingTimeout = 1;
//
//    conf1.iceBackupCandidatePairPingInterval = 1;
//
//    conf1.rtcpMuxPolicy = kRTCRtcpMuxPolicyRequire;
//
//    conf1.audioJitterBufferMaxPackets = 50;
//
//    conf1.tcpCandidatePolicy = kRTCTcpCandidatePolicyEnabled;
//
//    conf1.bundlePolicy = kRTCBundlePolicyBalanced;
//
//    conf1.iceTransportsType = kRTCIceTransportsTypeAll;
//
//    [peer setConfiguration:conf1];
    

    [self.peerConnections setObject:peer forKey:identifier];
}

- (void)createOfferForPeerWithID:(NSString *)peerID calleeName:(NSString*)calleeName
{
    self.calleeName = calleeName;
    
    RTCPeerConnection *peerConnection = [self.peerConnections objectForKey:peerID];
    
    [self.peerToRoleMap setObject:TLKPeerConnectionRoleInitiator forKey:peerID];
    
    [self createDataChannel:peerConnection];   // create data channel for chatting
    
    [peerConnection offerForConstraints:[self _mediaConstraints] completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
        
        [peerConnection setLocalDescription:sdp completionHandler:^(NSError * _Nullable error) {
            
            if (peerConnection.signalingState == RTCSignalingStateHaveLocalOffer)
            {
                [self.delegate webRTC:self didSendSDPOffer:sdp.sdp forPeerWithID:peerID calleeUser:self.calleeName allowVideo:[NSString stringWithFormat:@"%d",self.allowVideo]];
                
            }
            
        }];
    }];
}



-(void)createDataChannel:(RTCPeerConnection*)peerConnection  // create new data channel along with offer
{
    RTCDataChannelConfiguration* conf = [[RTCDataChannelConfiguration alloc] init];
    
    conf.maxRetransmits = 0;
    
    conf.isOrdered=false;
    
//    conf.maxRetransmitTimeMs = -1;
    conf.isNegotiated = false;
//    conf.streamId = 25;
    
    self.dataChannel =[peerConnection dataChannelForLabel:@"myLabel" configuration:conf];
    
//    dataChannel.delegate = self;
    
//    self.dataChannel = dataChannel;
    
}

//-(void)sendMessageUsingDataChannel:(NSString*)messageString
//{
//    RTCDataBuffer *buffer = [[RTCDataBuffer alloc] initWithData:[messageString dataUsingEncoding:NSUTF8StringEncoding] isBinary:NO];
//
//    BOOL x = [self.dataChannel sendData:buffer];
//
//    NSLog(@"data sent %d", x);
//}




//-(void)hangUpCall:(NSNotification*)noti
//{
//    NSString* currentUser = [[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_USER];
//    
//    [self removePeerConnectionForID:currentUser];
//    
//}
- (NSString *)identifierForPeer:(RTCPeerConnection *)peer
{
    NSArray *keys = [self.peerConnections allKeysForObject:peer];
    
    return (keys.count == 0) ? nil : keys[0];
}

//#pragma mark - RTCSessionDescriptionDelegate

// Note: all these delegate calls come back on a random background thread inside WebRTC,
// so all are bridged across to the main thread

//- (void)peerConnection:(RTCPeerConnection *)peerConnection didCreateSessionDescription:(RTCSessionDescription *)originalSdp error:(NSError *)error
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        RTCSessionDescription* sessionDescription = [[RTCSessionDescription alloc] initWithType:originalSdp.type sdp:originalSdp.description];
//
//        [peerConnection setLocalDescriptionWithDelegate:self sessionDescription:sessionDescription];
//
//    });
//}


//- (void)peerConnection:(RTCPeerConnection *)peerConnection didSetSessionDescriptionWithError:(NSError *)error
//{

//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (peerConnection.iceGatheringState == RTCICEGatheringGathering)
//        {
//
//            NSArray *keys = [self.peerConnections allKeysForObject:peerConnection];
//
//            if ([keys count] > 0)
//            {
//                NSArray *candidates = [self.peerToICEMap objectForKey:keys[0]];
//
//                for (RTCICECandidate* candidate in candidates)
//                {
//                    [peerConnection addICECandidate:candidate];
//
////                    NSLog(@"Added candidate from array, candidate = %@",candidate);
//                }
////                NSLog(@"Added total %d candidates",candidates.count);
//                [self.peerToICEMap removeObjectForKey:keys[0]];
//            }
//        }
//
//        if (peerConnection.signalingState == RTCSignalingHaveLocalOffer)
//        {
//            NSArray *keys = [self.peerConnections allKeysForObject:peerConnection];
//            if ([keys count] > 0)
//            {
//                NSString* sdp = peerConnection.localDescription.description;
//////
//                NSString* modifiedSDP = [self modifySDP:sdp];
//
//
//                 RTCSessionDescription* sessionDescription = [[RTCSessionDescription alloc] initWithType:peerConnection.localDescription.type sdp:modifiedSDP];
////                [self.delegate webRTC:self didSendSDPOffer:peerConnection.localDescription forPeerWithID:keys[0]];
//                [self.delegate webRTC:self didSendSDPOffer:sessionDescription forPeerWithID:keys[0] calleeUser:self.calleeName];
//
//            }
//        }
//        else if (peerConnection.signalingState == RTCSignalingHaveRemoteOffer)
//        {
//            [peerConnection createAnswerWithDelegate:self constraints:[self _mediaConstraints]];
//        }
//        else if (peerConnection.signalingState == RTCSignalingStable)
//        {
//            NSArray* keys = [self.peerConnections allKeysForObject:peerConnection];
//
//            if ([keys count] > 0)
//            {
//                NSString* role = [self.peerToRoleMap objectForKey:keys[0]];
//
//                if (role == TLKPeerConnectionRoleReceiver)
//                {
//
//                    //NSLog(@"Answer desc = %@",peerConnection.localDescription);
//
//                    NSString* modifiedSDP = [self modifySDP:peerConnection.localDescription.description];
//
//                    RTCSessionDescription* sessionDescription = [[RTCSessionDescription alloc] initWithType:peerConnection.localDescription.type sdp:modifiedSDP];
//
//
////                    [peerConnection setLocalDescriptionWithDelegate:self sessionDescription:sessionDescription];
//
//                    [self.delegate webRTC:self didSendSDPAnswer:sessionDescription forPeerWithID:keys[0] calleeUser:self.sdpSender];
//                }
//
//            }
//        }
//    });
//}


//-(NSString* )modifySDP:(NSString*)sdp
//{

//            NSRange mAudioTagRange = [sdp rangeOfString:@"m=audio "];
//
//            NSRange cInTagRange = [sdp rangeOfString:@"c=IN "];
//
//
//            int mAudioTotalLength = cInTagRange.location-mAudioTagRange.location-1;
//
//            NSString* newCInString = @"a=rtcp:9 IN IP4 0.0.0.0";
////
////
//            NSRange aRTCPSampleRange = [sdp rangeOfString:@"a=rtcp:"];
////
//        NSRange candidateRange1 = [sdp rangeOfString:@"a=candidate:"];
//
//            if (candidateRange1.length > 0)
//            {
//
//                int rtcpTotalLength = candidateRange1.location-aRTCPSampleRange.location-1;
//                //
//                //
//                NSRange cInRange = NSMakeRange(aRTCPSampleRange.location, rtcpTotalLength);
//                //
//                sdp = [sdp stringByReplacingCharactersInRange:cInRange withString:newCInString];
//            }
    
//
//            NSRange fingerPringTagRange = [sdp rangeOfString:@"a=fingerprint:"];
//
//            NSRange setUpTagRange = [sdp rangeOfString:@"a=setup:"];
    
   
//            NSMutableString *sdp1 = [[NSMutableString alloc] initWithString:sdp];

//            NSRange candidateTagRange = [sdp rangeOfString:@"a=candidate:"];
//
//            if (candidateTagRange.length > 0)
//            {
//                NSRange uFragTagRange = [sdp rangeOfString:@"a=ice-ufrag:"];
//
//                int candidateTotalLength = uFragTagRange.location-candidateTagRange.location-1;
//
//                NSRange candiateNewRange = NSMakeRange(candidateTagRange.location, candidateTotalLength);
//
//                [sdp1 stringByReplacingCharactersInRange:candiateNewRange withString:@""];
//            }
    
    
            //  [sdp1 insertString:@"a=ice-options:trickle\r\r" atIndex:fingerPringTagRange.location];
    
           // sdp1 = [sdp1 stringByAppendingString:@"\ra=end-of-candidates\r"];
    
//            sdp = [sdp1 stringByAppendingString:@"a=ice-options:trickle\n"];

           // sdp1 = [sdp1 stringByAppendingString:@"a=end-of-candidates\n"];

//            [sdp1 insertString:@"a=end-of-candidates\n" atIndex:fingerPringTagRange.location];
//    
           // [sdp1 insertString:@"a=ice-options:trickle\r\n" atIndex:fingerPringTagRange.location];
    
//            return sdp;

//}
#pragma mark - String utilities

- (NSString *)stringForSignalingState:(RTCSignalingState)state
{
    NSString *signalingStateString = nil;
    
    switch (state)
    {
        case RTCSignalingStateStable:
            signalingStateString = @"Stable";
            break;
        case RTCSignalingStateHaveLocalOffer:
            signalingStateString = @"Have Local Offer";
            break;
        case RTCSignalingStateHaveRemoteOffer:
            signalingStateString = @"Have Remote Offer";
            break;
        case RTCSignalingStateClosed:
            signalingStateString = @"Closed";
            break;
        default:
            signalingStateString = @"Other state";
            break;
    }
    
    return signalingStateString;
}

- (NSString *)stringForConnectionState:(RTCIceConnectionState)state
{
    NSString *connectionStateString = nil;
    switch (state)
    {
        case RTCIceConnectionStateNew:
            connectionStateString = @"New";
            break;
        case RTCIceConnectionStateChecking:
            connectionStateString = @"Checking";
            break;
        case RTCIceConnectionStateConnected:
            connectionStateString = @"Connected";
            break;
        case RTCIceConnectionStateCompleted:
            connectionStateString = @"Completed";
            break;
        case RTCIceConnectionStateFailed:
            connectionStateString = @"Failed";
            break;
        case RTCIceConnectionStateDisconnected:
            connectionStateString = @"Disconnected";
            break;
        case RTCIceConnectionStateClosed:
            connectionStateString = @"Closed";
            break;
        default:
            connectionStateString = @"Other state";
            break;
    }
    return connectionStateString;
}

- (NSString *)stringForGatheringState:(RTCIceGatheringState)state
{
    NSString *gatheringState = nil;
    switch (state)
    {
        case RTCIceGatheringStateNew:
            gatheringState = @"New";
            break;
        case RTCIceGatheringStateGathering:
            gatheringState = @"Gathering";
            break;
        case RTCIceGatheringStateComplete:
            gatheringState = @"Complete";
            break;
        default:
            gatheringState = @"Other state";
            break;
    }
    return gatheringState;
}


// Note: all these delegate calls come back on a random background thread inside WebRTC,
// so all are bridged across to the main thread

//- (void)peerConnectionOnError:(RTCPeerConnection *)peerConnection
//{
//    //    dispatch_async(dispatch_get_main_queue(), ^{
//    //    });
//}

//- (void)peerConnection:(RTCPeerConnection *)peerConnection signalingStateChanged:(RTCSignalingState)stateChanged
//{
//    dispatch_async(dispatch_get_main_queue(), ^
//    {
        // I'm seeing this, but not sure what to do with it yet
//        NSArray* keys = [self.peerConnections allKeysForObject:peerConnection];
//
//        [self.delegate webRTC:self sendCachedICECandidate:self.cachedCandidateToSendArray forPeerWithID:keys[0]];
//    });
//}

//- (void)peerConnection:(RTCPeerConnection *)peerConnection addedStream:(RTCMediaStream *)stream
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.delegate webRTC:self addedStream:stream forPeerWithID:[self identifierForPeer:peerConnection]];
//    });
//}

//- (void)peerConnection:(RTCPeerConnection *)peerConnection removedStream:(RTCMediaStream *)stream
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.delegate webRTC:self removedStream:stream forPeerWithID:[self identifierForPeer:peerConnection]];
//    });
//}

//- (void)peerConnectionOnRenegotiationNeeded:(RTCPeerConnection *)peerConnection
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"peerConnectionOnRenegotiationNeeded ?");
//    });
//}

//- (void)peerConnection:(RTCPeerConnection *)peerConnection iceConnectionChanged:(RTCIceConnectionState)newState
//{
//    [peerConnection close];
//    peerConnection = nil;
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        [self.delegate webRTC:self didObserveICEConnectionStateChange:newState forPeerWithID:[self identifierForPeer:peerConnection]];
//    });
//}

//- (void)peerConnection:(RTCPeerConnection *)peerConnection iceGatheringChanged:(RTCIceGatheringState)newState
//{

//    dispatch_async(dispatch_get_main_queue(), ^{
//
//
//        NSLog(@"peerConnection iceGatheringChanged?");
//
//        if (newState == RTCIceGatheringStateComplete)
//        {
//            if ([peerConnection.localDescription.type isEqualToString:@"offer"])
//            {
////                [peerConnection createOfferWithDelegate:self constraints:[self _mediaConstraints]];
////
//                NSArray* keys = [self.peerConnections allKeysForObject:peerConnection];
//
//                RTCSessionDescription* sessionDescription = [[RTCSessionDescription alloc] initWithType:peerConnection.localDescription.type sdp:peerConnection.localDescription.description];
//
////                [self.delegate webRTC:self didSendSDPOffer:sessionDescription forPeerWithID:keys[0] calleeUser:self.calleeName];
//            }
//            else
//            {
//                NSArray* keys = [self.peerConnections allKeysForObject:peerConnection];
////                if ([keys count] > 0)
////                {
////                    NSString* role = [self.peerToRoleMap objectForKey:keys[0]];
////                    if (role == TLKPeerConnectionRoleReceiver)
////                    {
//
//                        //NSLog(@"Answer desc = %@",peerConnection.localDescription);
//                        NSString* modifiedSDP = [self modifySDP:peerConnection.localDescription.description];
//
//                        RTCSessionDescription* sessionDescription = [[RTCSessionDescription alloc] initWithType:peerConnection.localDescription.type sdp:modifiedSDP];
//
//
////                        [self.delegate webRTC:self didSendSDPAnswer:sessionDescription forPeerWithID:keys[0] calleeUser:self.sdpSender];
//
//
////                    }
////
////                }
//            }
//        }
    
//    });
//}

//- (void)peerConnection:(RTCPeerConnection *)peerConnection gotICECandidate:(RTCIceCandidate *)candidate
//{
////    dispatch_async(dispatch_get_main_queue(), ^{
//
//        NSArray* keys = [self.peerConnections allKeysForObject:peerConnection];
//
//        if ([keys count] > 0)
//        {
////            [peerConnection addICECandidate:candidate];
//            NSLog(@"local candi. = %@",candidate);
//
//            [self.delegate webRTC:self didSendICECandidate:candidate forPeerWithID:keys[0]];
//        }
////    });
//}

//- (void)peerConnection:(RTCPeerConnection *)peerConnection didOpenDataChannel:(RTCDataChannel *)dataChannel
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"peerConnection didOpenDataChannel?");
//    });
//}

#pragma mark - RTCPeerConnectionDelegate

/** Called when the SignalingState changed. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didChangeSignalingState:(RTCSignalingState)stateChanged
{
    
}

/** Called when media is received on a new stream from remote peer. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
          didAddStream:(RTCMediaStream *)stream
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.delegate webRTC:self addedStream:stream forPeerWithID:[self identifierForPeer:peerConnection]];
        
        
    });
}

/** Called when a remote peer closes a stream.
 *  This is not called when RTCSdpSemanticsUnifiedPlan is specified.
 */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
       didRemoveStream:(RTCMediaStream *)stream
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate webRTC:self removedStream:stream forPeerWithID:[self identifierForPeer:peerConnection]];
    });
}

/** Called when negotiation is needed, for example ICE has restarted. */
- (void)peerConnectionShouldNegotiate:(RTCPeerConnection *)peerConnection
{
    
}

/** Called any time the IceConnectionState changes. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didChangeIceConnectionState:(RTCIceConnectionState)newState
{
    dispatch_async(dispatch_get_main_queue(), ^{
    
//        __weak TLKWebRTC* rtc = self;
//        if (newState == RTCIceConnectionStateDisconnected)
//        {
//
//        }
//        else
//        {
            [self.delegate webRTC:self didObserveICEConnectionStateChange:newState forPeerWithID:[self identifierForPeer:peerConnection]];

//        }
    });
}

/** Called any time the IceGatheringState changes. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didChangeIceGatheringState:(RTCIceGatheringState)newState
{
    NSLog(@"gathering state = %ld", newState);
}

/** New ice candidate has been found. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didGenerateIceCandidate:(RTCIceCandidate *)candidate
{
    NSArray* keys = [self.peerConnections allKeysForObject:peerConnection];
    
    if ([keys count] > 0)
    {
        //            [peerConnection addICECandidate:candidate];
        NSLog(@"local candi. = %@",candidate);
        
        [self.delegate webRTC:self didSendICECandidate:candidate forPeerWithID:keys[0] allowVideo:[NSString stringWithFormat:@"%d",self.allowVideo]];
    }
}

/** Called when a group of local Ice candidates have been removed. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didRemoveIceCandidates:(NSArray<RTCIceCandidate *> *)candidates
{
    
}

/** New data channel has been opened. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
    didOpenDataChannel:(RTCDataChannel *)dataChannel
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.delegate peerConnection:self peerConnection:peerConnection openedDataChannel:dataChannel];
        
//        NSLog(@"peerConnection didOpenDataChannel?");
    });
}

//-(void)dataChannelDidChangeState:(RTCDataChannel *)dataChannel
//{
//    NSLog(@"data channel state = %d", dataChannel.readyState);
//
//}
//-(void)dataChannel:(RTCDataChannel *)dataChannel didReceiveMessageWithBuffer:(RTCDataBuffer *)buffer
//{
//    NSString* newMessage = [[NSString alloc] initWithData:buffer.data encoding:NSUTF8StringEncoding];
//
//    NSLog(@"new message = %@ ", newMessage);
//
//    [self sendMessageUsingDataChannel:@"reply"];
//}


@end

