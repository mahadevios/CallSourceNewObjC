
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

#import "RTCPeerConnectionFactory.h"
#import "RTCPeerConnection.h"
#import "RTCICEServer.h"
#import "RTCPair.h"
#import "RTCMediaConstraints.h"
#import "RTCSessionDescription.h"
#import "RTCSessionDescriptionDelegate.h"
#import "RTCPeerConnectionDelegate.h"

#import "RTCAudioTrack.h"
#import "RTCAVFoundationVideoSource.h"
#import "RTCVideoTrack.h"
#import "NSString+URLEncodedString.h"

@interface TLKWebRTC () <
RTCSessionDescriptionDelegate,
RTCPeerConnectionDelegate>

@property (readwrite, nonatomic) RTCMediaStream *localMediaStream;

@property (nonatomic, strong) RTCPeerConnectionFactory *peerFactory;
@property (nonatomic, strong) NSMutableDictionary *peerConnections;
@property (nonatomic, strong) NSMutableDictionary *peerToRoleMap;
@property (nonatomic, strong) NSMutableDictionary *peerToICEMap;

@property (nonatomic) BOOL allowVideo;
@property (nonatomic, strong) AVCaptureDevice *videoDevice;

@property (nonatomic, strong) NSMutableArray *iceServers;

@end

static NSString * const TLKPeerConnectionRoleInitiator = @"TLKPeerConnectionRoleInitiator";
static NSString * const TLKPeerConnectionRoleReceiver = @"TLKPeerConnectionRoleReceiver";
static NSString * const TLKWebRTCSTUNHostname2 = @"stun:stun.l.google.com:19302";
//static NSString * const TLKWebRTCSTUNHostname2 = @"turn:66.228.45.110:3478";
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
    self.iceCandidateDictArray = [NSMutableArray new];
    
    return [self initWithVideo:NO];
}


-(void) setSDPGotFromServer:(NSNotification *)notification
{
    
    NSDictionary* dic = notification.object;
    
    NSDictionary* apsDict = [dic objectForKey:@"aps"];
    
    [apsDict valueForKey:@"alert"];
    
    NSString* sdp =[apsDict objectForKey:@"alert"];
    
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


   // [sdp1 insertString:@"a=ice-options:trickle\r" atIndex:fingerPringTagRange.location];

    //NSString* updatedSDP = [sdp.description stringByAppendingString:@"a=ice-options:trickle"];
//
    NSRange candidateTagRange = [sdp rangeOfString:@"a=candidate:"];
    
    if (candidateTagRange.length > 0)
    {
        NSRange uFragTagRange = [sdp rangeOfString:@"a=ice-ufrag:"];
        
        int candidateTotalLength = uFragTagRange.location-candidateTagRange.location-1;
        
        NSRange candiateNewRange = NSMakeRange(candidateTagRange.location, candidateTotalLength);
        
        [sdp1 stringByReplacingCharactersInRange:candiateNewRange withString:@""];
    }
    
    NSLog(@"Got new SDP from Noti.= %@", sdp1);
    
//    NSArray* keys = [self.peerConnections allKeysForObject:peerConnection];
//    
//    NSString* role = [self.peerToRoleMap objectForKey:keys[0]];
//    if (role == TLKPeerConnectionRoleReceiver)
//    {
//        
//    }
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        RTCSessionDescription *remoteDesc = [[RTCSessionDescription alloc] initWithType:@"offer" sdp:sdp1];
        
        [self setRemoteDescription:remoteDesc forPeerWithID:@"iPad" receiver:true];
        
    }
    else
    {
        RTCSessionDescription *remoteDesc = [[RTCSessionDescription alloc] initWithType:@"answer" sdp:sdp1];
        
        [self setRemoteDescription:remoteDesc forPeerWithID:@"iPhone" receiver:false];
        
    }
    // });
}


-(void) setCandidatesGotFromServer:(NSNotification *)notification
{
    // dispatch_async(dispatch_get_main_queue(), ^{
    
    
    NSDictionary* dic = notification.object;
    NSDictionary* apsDict = [dic objectForKey:@"aps"];
    [apsDict valueForKey:@"alert"];
    NSString* candidates =[apsDict valueForKey:@"alert"];
    
    //NSData *authData = [candidates1 dataUsingEncoding:NSUTF8StringEncoding];

    //NSString* candidates = [authData base64EncodedStringWithOptions:0];
   // NSString *escapedString = [candidates stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
   // NSLog(@"escapedString: %@", escapedString);
    
    
    
    NSData *data1 = [candidates dataUsingEncoding:NSUTF8StringEncoding];
    NSError* err;
    
    self.iceCandidateGotFromServerArray = [NSMutableArray new];
    
    
    self.iceCandidateGotFromServerArray = [NSJSONSerialization JSONObjectWithData:data1 options:NSJSONReadingAllowFragments error:&err];
    
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        
        for (int i = 0; i< self.iceCandidateGotFromServerArray.count; i++)
        {
            NSDictionary* dic = self.iceCandidateGotFromServerArray[i];
            
            NSString* sdp = [dic valueForKey:CANDIDATE_SDP];
            
            NSRange uFragTagRange = [sdp rangeOfString:@"ufrag "];
            
            NSRange sdpRange = [sdp rangeOfString:sdp];
            
            
            int sdpWOufragLength = uFragTagRange.location;
            
            int ufragTotalLength = sdpRange.length - sdpWOufragLength;
            
            NSRange uFragRange = NSMakeRange(uFragTagRange.location+6, ufragTotalLength-6);
            
            NSString* uFragTotalSubString = [sdp substringWithRange:uFragRange];
            
            NSString* ufragReplaceString = [uFragTotalSubString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            
            sdp = [sdp stringByReplacingCharactersInRange:uFragRange withString:ufragReplaceString];
            

            RTCICECandidate *candidate = [[RTCICECandidate alloc] initWithMid:[dic valueForKey:SDP_MID]
                                                                        index:(int)[dic valueForKey:SDP_MLINE_INDEX]
                                                                          sdp:sdp];

            NSLog(@"Got new Canidate from Noti. =%@", candidate);

            
            [self addICECandidate:candidate forPeerWithID:@"iPad"];
            
        }
    }
    else
    {
        for (int i = 0; i< self.iceCandidateGotFromServerArray.count; i++)
        {
            NSDictionary* dic = self.iceCandidateGotFromServerArray[i];
            
            NSString* sdp = [dic valueForKey:CANDIDATE_SDP];
            
            NSRange uFragTagRange = [sdp rangeOfString:@"ufrag "];
            
            NSRange sdpRange = [sdp rangeOfString:sdp];
            
            
            int sdpWOufragLength = uFragTagRange.location;
            
            int ufragTotalLength = sdpRange.length - sdpWOufragLength;
            
            NSRange uFragRange = NSMakeRange(uFragTagRange.location+6, ufragTotalLength-6);
            
            NSString* uFragTotalSubString = [sdp substringWithRange:uFragRange];
            
            NSString* ufragReplaceString = [uFragTotalSubString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            
            sdp = [sdp stringByReplacingCharactersInRange:uFragRange withString:ufragReplaceString];
            
            
            RTCICECandidate *candidate = [[RTCICECandidate alloc] initWithMid:[dic valueForKey:SDP_MID]
                                                                        index:(int)[dic valueForKey:SDP_MLINE_INDEX]
                                                                          sdp:sdp];
            
            NSLog(@"Got new Canidate from Noti. =%@", candidate);

            
            [self addICECandidate:candidate forPeerWithID:@"iPhone"];
            
        }
        
        
    }
    
    // });
    
}
- (void)_commonSetup {
    _peerFactory = [[RTCPeerConnectionFactory alloc] init];
    _peerConnections = [NSMutableDictionary dictionary];
    _peerToRoleMap = [NSMutableDictionary dictionary];
    _peerToICEMap = [NSMutableDictionary dictionary];
    
    self.iceServers = [NSMutableArray new];
    
//    RTCICEServer *defaultTurnServer = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:TLKWebRTCSTUNHostname2] username:@"" password:@""];

//    RTCICEServer *defaultTurnServer = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:TLKWebRTCSTUNHostname2] username:@"mahadevmandale@yahoo.com" password:@"Mahadev7"];
//
////    RTCICEServer *defaultTurnServer = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:TLKWebRTCSTUNHostname2] username:@"297e711a-17d0-11e8-94b2-8881540efb1e" password:@"297e71ce-17d0-11e8-b560-7980d1185d80"];
//
////    [self.iceServers addObject:defaultTurnServer];
//    [self.iceServers addObject:defaultTurnServer];

    [RTCPeerConnectionFactory initializeSSL];
    
    [self _createLocalStream];
}

- (void)_createLocalStream {
    
    self.localMediaStream = [self.peerFactory mediaStreamWithLabel:[[NSUUID UUID] UUIDString]];
    
    RTCAudioTrack *audioTrack = [self.peerFactory audioTrackWithID:[[NSUUID UUID] UUIDString]];
    [self.localMediaStream addAudioTrack:audioTrack];
    

    if (self.allowVideo) {
        RTCAVFoundationVideoSource *videoSource = [[RTCAVFoundationVideoSource alloc] initWithFactory:self.peerFactory constraints:nil];
        videoSource.useBackCamera = NO;
        RTCVideoTrack *videoTrack = [[RTCVideoTrack alloc] initWithFactory:self.peerFactory source:videoSource trackId:[[NSUUID UUID] UUIDString]];
        [self.localMediaStream addVideoTrack:videoTrack];
    }
}

- (RTCMediaConstraints *)_mediaConstraints {
    RTCPair *audioConstraint = [[RTCPair alloc] initWithKey:@"OfferToReceiveAudio" value:@"true"];
    RTCPair *videoConstraint = [[RTCPair alloc] initWithKey:@"OfferToReceiveVideo" value:self.allowVideo ? @"true" : @"false"];
    RTCPair *sctpConstraint = [[RTCPair alloc] initWithKey:@"internalSctpDataChannels" value:@"true"];
    RTCPair *dtlsConstraint = [[RTCPair alloc] initWithKey:@"DtlsSrtpKeyAgreement" value:@"true"];
//    RTCPair *dtlsConstraint1 = [[RTCPair alloc] initWithKey:@"a=transport_options" value:@"trickle"];

    
 
    
    return [[RTCMediaConstraints alloc] initWithMandatoryConstraints:@[audioConstraint, videoConstraint] optionalConstraints:@[sctpConstraint, dtlsConstraint]];
}

#pragma mark - ICE server

- (void)addICEServer:(RTCICEServer *)server {
    BOOL isStun = [server.URI.scheme isEqualToString:@"stun"];
    if (isStun) {
        // Array of servers is always stored with stun server in first index, and we only want one,
        // so if this is a stun server, replace it
        [self.iceServers replaceObjectAtIndex:0 withObject:server];
    }
    else {
        [self.iceServers addObject:server];
    }
}

#pragma mark - Peer Connections

- (NSString *)identifierForPeer:(RTCPeerConnection *)peer
{
    NSArray *keys = [self.peerConnections allKeysForObject:peer];
    return (keys.count == 0) ? nil : keys[0];
}

- (void)addPeerConnectionForID:(NSString *)identifier iceServerArray:(NSMutableArray*)iceServerArray;
{
    self.XIRiceServerArray = iceServerArray;
    
    for (NSDictionary* serverCredDict in self.XIRiceServerArray)
    {
        NSString* url = [serverCredDict valueForKey:@"url"];
        NSString* username = [serverCredDict valueForKey:@"username"];
        NSString* credential = [serverCredDict valueForKey:@"credential"];

        if (username == nil)
        {
            username = @"";
        }
        if (credential == nil)
        {
            credential = @"";
        }
        RTCICEServer *defaultTurnServer = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:url] username:username password:credential];


        [self.iceServers addObject:defaultTurnServer];
    }
    
    RTCPeerConnection *peer = [self.peerFactory peerConnectionWithICEServers:[self iceServers] constraints:[self _mediaConstraints] delegate:self];
    [peer addStream:self.localMediaStream];
    
    [self.peerConnections setObject:peer forKey:identifier];
}

- (void)removePeerConnectionForID:(NSString *)identifier {
    RTCPeerConnection* peer = self.peerConnections[identifier];
    [self.peerConnections removeObjectForKey:identifier];
    [self.peerToRoleMap removeObjectForKey:identifier];
    [peer close];
}

#pragma mark -

- (void)createOfferForPeerWithID:(NSString *)peerID {
    RTCPeerConnection *peerConnection = [self.peerConnections objectForKey:peerID];
    [self.peerToRoleMap setObject:TLKPeerConnectionRoleInitiator forKey:peerID];
    [peerConnection createOfferWithDelegate:self constraints:[self _mediaConstraints]];
}

- (void)setRemoteDescription:(RTCSessionDescription *)remoteSDP forPeerWithID:(NSString *)peerID receiver:(BOOL)isReceiver
{
    RTCPeerConnection *peerConnection = [self.peerConnections objectForKey:peerID];
    if (isReceiver)
    {
        [self.peerToRoleMap setObject:TLKPeerConnectionRoleReceiver forKey:peerID];
    }

    [peerConnection setRemoteDescriptionWithDelegate:self sessionDescription:remoteSDP];
    
    
}

- (void)addICECandidate:(RTCICECandidate*)candidate forPeerWithID:(NSString *)peerID {
    RTCPeerConnection *peerConnection = [self.peerConnections objectForKey:peerID];
    
    if (peerConnection.iceGatheringState == RTCICEGatheringNew)
    {
        NSMutableArray *candidates = [self.peerToICEMap objectForKey:peerID];
        if (!candidates) {
            candidates = [NSMutableArray array];
            [self.peerToICEMap setObject:candidates forKey:peerID];
        }
        [candidates addObject:candidate];
        NSLog(@"candidate added to stack from Noti");
    } else
    {
    
//        if (peerConnection.remoteDescription == nil)
//        {
//            [self.iceCandidateDictArray addObject:candidate];
//        }
//        else
//        {
//            for (RTCICECandidate* candidate in self.iceCandidateDictArray)
//            {
//                [peerConnection addICECandidate:candidate];
//
//                NSLog(@"candidate added from array");
//            }
//            [self.iceCandidateDictArray removeAllObjects];

            [peerConnection addICECandidate:candidate];
            
            NSLog(@"candidate added directly from Noti");
//        }
        
        
        
    }
}

#pragma mark - RTCSessionDescriptionDelegate

// Note: all these delegate calls come back on a random background thread inside WebRTC,
// so all are bridged across to the main thread

- (void)peerConnection:(RTCPeerConnection *)peerConnection didCreateSessionDescription:(RTCSessionDescription *)originalSdp error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        
//        NSString* updatedSDP = [sdp.description stringByAppendingString:@"a=ice-options:trickle"];
        
//        RTCSessionDescription* sessionDescription = [[RTCSessionDescription alloc] initWithType:sdp.type sdp:updatedSDP];
        NSString* sdp = originalSdp.description;
//
//        NSRange mAudioTagRange = [sdp rangeOfString:@"m=audio "];
//
//        NSRange cInTagRange = [sdp rangeOfString:@"c=IN "];
//
//
//        int mAudioTotalLength = cInTagRange.location-mAudioTagRange.location-1;
//
//
//        //NSRange mAudioRange = NSMakeRange(mAudioTagRange.location, mAudioTotalLength);
//
//
//        //NSString* newMAudioString = @"m=audio 1 RTP/AVP 0 96\r";
//
//        //sdp = [sdp stringByReplacingCharactersInRange:mAudioRange withString:newMAudioString];
//
//        NSString* newCInString = @"c=IN IP4 0.0.0.0\r";
//
//        NSRange cInTagRange1 = [sdp rangeOfString:@"c=IN "];
//
//        NSRange aRTCPSampleRange = [sdp rangeOfString:@"a=rtcp:"];
//
//        int cInTotalLength = aRTCPSampleRange.location-cInTagRange1.location-1;
//
//
//        NSRange cInRange = NSMakeRange(cInTagRange1.location, cInTotalLength);
//
//        sdp = [sdp stringByReplacingCharactersInRange:cInRange withString:newCInString];
//
//        NSRange fingerPringTagRange = [sdp rangeOfString:@"a=fingerprint:"];
//
//        NSMutableString *sdp1 = [NSMutableString stringWithString:sdp];
//
//
//
//        //  [sdp1 insertString:@"a=ice-options:trickle\r\r" atIndex:fingerPringTagRange.location];
//
////        [sdp1 insertString:@"\ra=end-of-candidates\r" atIndex:fingerPringTagRange.location];
//
//        [sdp1 insertString:@"a=ice-options:trickle\r" atIndex:fingerPringTagRange.location];
        
        RTCSessionDescription* sessionDescription = [[RTCSessionDescription alloc] initWithType:originalSdp.type sdp:sdp];
        
        [peerConnection setLocalDescriptionWithDelegate:self sessionDescription:sessionDescription];
        
        
    });
}


- (void)peerConnection:(RTCPeerConnection *)peerConnection didSetSessionDescriptionWithError:(NSError *)error {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (peerConnection.iceGatheringState == RTCICEGatheringGathering)
        {
        
            NSArray *keys = [self.peerConnections allKeysForObject:peerConnection];
            if ([keys count] > 0)
            {
                NSArray *candidates = [self.peerToICEMap objectForKey:keys[0]];
                for (RTCICECandidate* candidate in candidates)
                {
                    [peerConnection addICECandidate:candidate];
                    NSLog(@"Added candidate from array, candidate = %@",candidate);
                }
                NSLog(@"Added total %d candidates",candidates.count);
                [self.peerToICEMap removeObjectForKey:keys[0]];
            }
        }
        
        if (peerConnection.signalingState == RTCSignalingHaveLocalOffer)
        {
            NSArray *keys = [self.peerConnections allKeysForObject:peerConnection];
            if ([keys count] > 0)
            {
                NSString* sdp = peerConnection.localDescription.description;
//
               
                //NSRange iceTagRange = [sdp rangeOfString:@"a=fingerprint:"];

                NSString* modifiedSDP = [self modifySDP:sdp];
                
                //[peerConnection.localDescription setValue:@"trickle" forKey:@"a=ice-options"];
               // [peerConnection.localDescription setValue:@"-" forUndefinedKey:@"s"];
               // [peerConnection.localDescription setValue:@"trickle" forKey:@"a=ice-options"];
                
                
                 RTCSessionDescription* sessionDescription = [[RTCSessionDescription alloc] initWithType:peerConnection.localDescription.type sdp:modifiedSDP];
//                [self.delegate webRTC:self didSendSDPOffer:peerConnection.localDescription forPeerWithID:keys[0]];
                [self.delegate webRTC:self didSendSDPOffer:sessionDescription forPeerWithID:keys[0]];

            }
        }
        else if (peerConnection.signalingState == RTCSignalingHaveRemoteOffer)
        {
            [peerConnection createAnswerWithDelegate:self constraints:[self _mediaConstraints]];
        }
        else if (peerConnection.signalingState == RTCSignalingStable)
        {
            NSArray* keys = [self.peerConnections allKeysForObject:peerConnection];
            if ([keys count] > 0)
            {
                NSString* role = [self.peerToRoleMap objectForKey:keys[0]];
                if (role == TLKPeerConnectionRoleReceiver)
                {
                    
                    //NSLog(@"Answer desc = %@",peerConnection.localDescription);
                    
                    NSString* modifiedSDP = [self modifySDP:peerConnection.localDescription.description];
                    
                    RTCSessionDescription* sessionDescription = [[RTCSessionDescription alloc] initWithType:peerConnection.localDescription.type sdp:modifiedSDP];
                    
                    [self.delegate webRTC:self didSendSDPAnswer:sessionDescription forPeerWithID:keys[0]];
                }
               
            }
        }
    });
}


-(NSString* )modifySDP:(NSString*)sdp
{
    
            NSRange mAudioTagRange = [sdp rangeOfString:@"m=audio "];

            NSRange cInTagRange = [sdp rangeOfString:@"c=IN "];


            int mAudioTotalLength = cInTagRange.location-mAudioTagRange.location-1;

            NSString* newCInString = @"c=IN IP4 0.0.0.0\r";

            NSRange cInTagRange1 = [sdp rangeOfString:@"c=IN "];

            NSRange aRTCPSampleRange = [sdp rangeOfString:@"a=rtcp:"];

            int cInTotalLength = aRTCPSampleRange.location-cInTagRange1.location-1;


            NSRange cInRange = NSMakeRange(cInTagRange1.location, cInTotalLength);

            sdp = [sdp stringByReplacingCharactersInRange:cInRange withString:newCInString];

            NSRange fingerPringTagRange = [sdp rangeOfString:@"a=fingerprint:"];
//
//            NSRange setUpTagRange = [sdp rangeOfString:@"a=setup:"];
    
            NSMutableString *sdp1 = [[NSMutableString alloc] initWithString:sdp];
    
            NSRange candidateTagRange = [sdp rangeOfString:@"a=candidate:"];

            if (candidateTagRange.length > 0)
            {
                NSRange uFragTagRange = [sdp rangeOfString:@"a=ice-ufrag:"];
                
                int candidateTotalLength = uFragTagRange.location-candidateTagRange.location-1;
                
                NSRange candiateNewRange = NSMakeRange(candidateTagRange.location, candidateTotalLength);
                
                [sdp1 stringByReplacingCharactersInRange:candiateNewRange withString:@""];
            }
    
    
            //  [sdp1 insertString:@"a=ice-options:trickle\r\r" atIndex:fingerPringTagRange.location];
    
           // sdp1 = [sdp1 stringByAppendingString:@"\ra=end-of-candidates\r"];
    
            //sdp1 = [sdp1 stringByAppendingString:@"a=ice-options:trickle\n"];
    
           // sdp1 = [sdp1 stringByAppendingString:@"a=end-of-candidates\n"];

            //[sdp1 insertString:@"\ra=end-of-candidates\r" atIndex:fingerPringTagRange.location];
    
            [sdp1 insertString:@"a=ice-options:trickle\n" atIndex:fingerPringTagRange.location];
    
            return sdp1;
    
}
#pragma mark - String utilities

- (NSString *)stringForSignalingState:(RTCSignalingState)state {
    NSString *signalingStateString = nil;
    switch (state) {
        case RTCSignalingStable:
            signalingStateString = @"Stable";
            break;
        case RTCSignalingHaveLocalOffer:
            signalingStateString = @"Have Local Offer";
            break;
        case RTCSignalingHaveRemoteOffer:
            signalingStateString = @"Have Remote Offer";
            break;
        case RTCSignalingClosed:
            signalingStateString = @"Closed";
            break;
        default:
            signalingStateString = @"Other state";
            break;
    }
    
    return signalingStateString;
}

- (NSString *)stringForConnectionState:(RTCICEConnectionState)state {
    NSString *connectionStateString = nil;
    switch (state) {
        case RTCICEConnectionNew:
            connectionStateString = @"New";
            break;
        case RTCICEConnectionChecking:
            connectionStateString = @"Checking";
            break;
        case RTCICEConnectionConnected:
            connectionStateString = @"Connected";
            break;
        case RTCICEConnectionCompleted:
            connectionStateString = @"Completed";
            break;
        case RTCICEConnectionFailed:
            connectionStateString = @"Failed";
            break;
        case RTCICEConnectionDisconnected:
            connectionStateString = @"Disconnected";
            break;
        case RTCICEConnectionClosed:
            connectionStateString = @"Closed";
            break;
        default:
            connectionStateString = @"Other state";
            break;
    }
    return connectionStateString;
}

- (NSString *)stringForGatheringState:(RTCICEGatheringState)state {
    NSString *gatheringState = nil;
    switch (state) {
        case RTCICEGatheringNew:
            gatheringState = @"New";
            break;
        case RTCICEGatheringGathering:
            gatheringState = @"Gathering";
            break;
        case RTCICEGatheringComplete:
            gatheringState = @"Complete";
            break;
        default:
            gatheringState = @"Other state";
            break;
    }
    return gatheringState;
}

#pragma mark - RTCPeerConnectionDelegate

// Note: all these delegate calls come back on a random background thread inside WebRTC,
// so all are bridged across to the main thread

- (void)peerConnectionOnError:(RTCPeerConnection *)peerConnection {
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection signalingStateChanged:(RTCSignalingState)stateChanged {
    dispatch_async(dispatch_get_main_queue(), ^{
        // I'm seeing this, but not sure what to do with it yet
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection addedStream:(RTCMediaStream *)stream {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate webRTC:self addedStream:stream forPeerWithID:[self identifierForPeer:peerConnection]];
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection removedStream:(RTCMediaStream *)stream {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate webRTC:self removedStream:stream forPeerWithID:[self identifierForPeer:peerConnection]];
    });
}

- (void)peerConnectionOnRenegotiationNeeded:(RTCPeerConnection *)peerConnection {
    dispatch_async(dispatch_get_main_queue(), ^{
        //    [self.peerConnection createOfferWithDelegate:self constraints:[self mediaConstraints]];
        // Is this delegate called when creating a PC that is going to *receive* an offer and return an answer?
//        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone )
//        {
//            [peerConnection createOfferWithDelegate:self constraints:[self _mediaConstraints]];
//        }
        NSLog(@"peerConnectionOnRenegotiationNeeded ?");
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection iceConnectionChanged:(RTCICEConnectionState)newState {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate webRTC:self didObserveICEConnectionStateChange:newState forPeerWithID:[self identifierForPeer:peerConnection]];
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection iceGatheringChanged:(RTCICEGatheringState)newState {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"peerConnection iceGatheringChanged?");
        
        if (newState == RTCICEGatheringComplete)
        {
            if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone )
            {
                //[peerConnection createOfferWithDelegate:self constraints:[self _mediaConstraints]];
            }
            else
            {
                NSArray* keys = [self.peerConnections allKeysForObject:peerConnection];
                if ([keys count] > 0)
                {
                    NSString* role = [self.peerToRoleMap objectForKey:keys[0]];
                    if (role == TLKPeerConnectionRoleReceiver)
                    {
                        
                        //NSLog(@"Answer desc = %@",peerConnection.localDescription);
                        
                        
                           //  [self.delegate webRTC:self didSendSDPAnswer:peerConnection.localDescription forPeerWithID:keys[0]];
                       
                    }
                    
                }
            }
        }
        
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection gotICECandidate:(RTCICECandidate *)candidate {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSArray* keys = [self.peerConnections allKeysForObject:peerConnection];
        if ([keys count] > 0) {
            //[self performSelector:@selector(sendICE:) withObject:candidate afterDelay:5];
            //NSLog(@"Got candiate in delegate = %@",candidate);
            //[self.iceCandidateDictArray addObject:candidate];
//            if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone )
//            {
//                [peerConnection createOfferWithDelegate:self constraints:[self _mediaConstraints]];
//            }
            [self.delegate webRTC:self didSendICECandidate:candidate forPeerWithID:keys[0]];
        }
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didOpenDataChannel:(RTCDataChannel *)dataChannel {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"peerConnection didOpenDataChannel?");
    });
}

//-(void)sendICE:(RTCICECandidate*)candidate
//{
//
//    [self.delegate webRTC:self didSendICECandidate:candidate forPeerWithID:keys[0]];
//
//}

@end

