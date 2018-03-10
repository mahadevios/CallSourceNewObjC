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

// https://www.w3.org/TR/webrtc/#peer-to-peer-data-api   webrtc RTC Api;s and explan
#import "WebRTC.h"

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

@interface WebRTC () <
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


//static NSString * const TLKWebRTCSTUNHostname1 = @"turn:192.168.3.75:3478";
//static NSString * const TLKWebRTCSTUNHostname2 = @"stun:stun2.l.google.com:19302";

static NSString * const TLKPeerConnectionRoleInitiator = @"TLKPeerConnectionRoleInitiator";
static NSString * const TLKPeerConnectionRoleReceiver = @"TLKPeerConnectionRoleReceiver";

static NSString * const TLKWebRTCSTUNHostname1 = @"stun:stun.l.google.com:19302";
static NSString * const twelveConnect = @"stun:stun.12connect.com:3478";
static NSString * const cryptonit = @"stun:stun.cryptonit.net:3478";
static NSString * const oneAndOne = @"stun:stun.1und1.de:3478";
static NSString * const twoTalk = @"stun:stun.2talk.co.nz:3478";
static NSString * const twoTalkOne = @"stun:stun.2talk.com:3478";
static NSString * const threeCLogic = @"stun:stun.3clogic.com:3478";
static NSString * const threeCX = @"stun:stun.3cx.com:3478";
static NSString * const aa = @"stun:stun.aa.net.uk:3478";
static NSString * const acrobits = @"stun:stun.acrobits.cz:3478";

//static NSString * const TLKWebRTCSTUNHostname1 = @"stun:stun2.l.google.com:19302";
//static NSString * const TLKWebRTCSTUNHostname2 = @"turn:numb.viagenie.ca:3478";

static NSString * const TLKWebRTCSTUNHostname2 = @"turn:66.228.45.110:3478";
//static NSString * const TLKWebRTCSTUNHostname2 = @"turn:193.147.51.36:3478";


//static NSString * const TLKWebRTCSTUNHostname2 = @"turn:numb.viagenie.ca";

//turn:homeo@turn.bistri.com:80

//static NSString * const TLKWebRTCSTUNHostname2 = @"turn:127.0.0.1:3478";
//static NSString * const TLKWebRTCSTUNHostname3 = @"turn:192.168.2.1:3478";

//static NSString * const TLKWebRTCSTUNHostname1 = @"192.168.2.1:3478";



@implementation WebRTC

#pragma mark - object lifecycle

- (instancetype)initWithVideoDevice:(AVCaptureDevice *)device
{
	self = [super init];
	if (self) {
		if (device) {
			_allowVideo = YES;
			_videoDevice = device;
		}
		[self _commonSetup];
	}
	return self;
}

- (instancetype)initWithVideo:(BOOL)allowVideo {
	// Set front camera as the default device
	AVCaptureDevice* frontCamera;
	if (allowVideo) {
		frontCamera = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] lastObject];
	}
	return [self initWithVideoDevice:frontCamera];
}

- (instancetype)init
{
	// Use default device
   
	return [self initWithVideo:NO];
}


-(void) setSDPGotFromServer:(NSNotification *)notification
{
    // check for signaling state also
    
    //dispatch_async(dispatch_get_main_queue(), ^{
 
    NSDictionary* dic = notification.object;
    
    NSDictionary* apsDict = [dic objectForKey:@"aps"];
    [apsDict valueForKey:@"alert"];
    NSString* sdp =[apsDict valueForKey:@"alert"];
    
    NSLog(@"Got new SDP from Noti.= %@", sdp);
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        RTCSessionDescription *remoteDesc = [[RTCSessionDescription alloc] initWithType:@"offer" sdp:sdp];

        [self setRemoteDescription:remoteDesc forPeerWithID:@"iPad" receiver:true];

    }
    else
    {
        RTCSessionDescription *remoteDesc = [[RTCSessionDescription alloc] initWithType:@"answer" sdp:sdp];

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
    
    NSLog(@"Got new Canidate from Noti. =%@", candidates);

    NSData *data1 = [candidates dataUsingEncoding:NSUTF8StringEncoding];
    NSError* err;
    
    self.iceCandidateGotFromServerArray = [NSMutableArray new];
    
    self.iceCandidateGotFromServerArray = [NSJSONSerialization JSONObjectWithData:data1 options:NSJSONReadingAllowFragments error:&err];
    
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        
        for (int i = 0; i< self.iceCandidateGotFromServerArray.count; i++)
        {
            NSDictionary* dic = self.iceCandidateGotFromServerArray[i];
            
            RTCICECandidate *candidate = [[RTCICECandidate alloc] initWithMid:[dic valueForKey:SDP_MID]
                                                                        index:(int)[dic valueForKey:SDP_MLINE_INDEX]
                                                                          sdp:[dic valueForKey:CANDIDATE_SDP]];
            [self addICECandidate:candidate forPeerWithID:@"iPad"];

        }
    }
    else
    {
        for (int i = 0; i< self.iceCandidateGotFromServerArray.count; i++)
        {
            NSDictionary* dic = self.iceCandidateGotFromServerArray[i];
            
            RTCICECandidate *candidate = [[RTCICECandidate alloc] initWithMid:[dic valueForKey:SDP_MID]
                                                                        index:(int)[dic valueForKey:SDP_MLINE_INDEX]
                                                                          sdp:[dic valueForKey:CANDIDATE_SDP]];
            [self addICECandidate:candidate forPeerWithID:@"iPhone"];

        }
        
        
    }

     // });
    
}

- (void)_commonSetup
{
    
    _peerFactory = [[RTCPeerConnectionFactory alloc] init];
    _peerConnections = [NSMutableDictionary dictionary];
    _peerToRoleMap = [NSMutableDictionary dictionary];
    _peerToICEMap = [NSMutableDictionary dictionary];
    
    self.iceServers = [NSMutableArray new];
    RTCICEServer *defaultStunServer = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:TLKWebRTCSTUNHostname1] username:@"" password:@""];
    RTCICEServer *defaultTurnServer = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:TLKWebRTCSTUNHostname2] username:@"mahadevmandale@yahoo.com" password:@"Mahadev7"];
//    RTCICEServer *defaultTurnServer = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:TLKWebRTCSTUNHostname2] username:@"mandale.mahadev7@gmail.com" password:@"Mahadev7"];
//    RTCICEServer *defaultTurnServer = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:TLKWebRTCSTUNHostname2] username:@"kuldeepkulkarni1234@gmail.com" password:@"kuldeep@123"];

    
//       RTCICEServer *defaultStunServer = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:TLKWebRTCSTUNHostname1] username:@"" password:@""];
    //    RTCICEServer *defaultStunServer1 = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:TLKWebRTCSTUNHostname] username:@"" password:@""];
    
   // RTCICEServer *defaultStunServer2 = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:TLKWebRTCSTUNHostname] username:@"" password:@""];
//    RTCICEServer *defaultStunServer3 = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:twelveConnect] username:@"" password:@""];
//    RTCICEServer *defaultStunServer4 = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:cryptonit] username:@"" password:@""];
//    RTCICEServer *defaultStunServer5 = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:oneAndOne] username:@"" password:@""];
//    RTCICEServer *defaultStunServer6 = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:twoTalk] username:@"" password:@""];
//    RTCICEServer *defaultStunServer7 = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:twoTalk] username:@"" password:@""];
//    RTCICEServer *defaultStunServer8 = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:twoTalkOne] username:@"" password:@""];
//    RTCICEServer *defaultStunServer9 = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:threeCLogic] username:@"" password:@""];
//
//    RTCICEServer *defaultStunServer10 = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:threeCX] username:@"" password:@""];
//    RTCICEServer *defaultStunServer11 = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:aa] username:@"" password:@""];
//    RTCICEServer *defaultStunServer12= [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:acrobits] username:@"" password:@""];
//
    
//    RTCICEServer *defaultTurnnServer12= [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:@"stun:stun.l.google.com:19302"] username:@"" password:@""];
    
//    RTCICEServer *defaultTurnnServer13= [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:@"turn:turn.quickblox.com:3478?transport=udp"] username:@"quickblox" password:@"baccb97ba2d92d71e26eb9886da5f1e0"];
//
//    RTCICEServer *defaultTurnnServer14= [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:@"stun:turn.quickblox.com"] username:@"quickblox" password:@"baccb97ba2d92d71e26eb9886da5f1e0"];
//
//    RTCICEServer *defaultTurnnServer15= [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:@"turn:turn.quickblox.com:3478?transport=tcp"] username:@"quickblox" password:@"baccb97ba2d92d71e26eb9886da5f1e0"];
//
    
   // [self.iceServers addObject:defaultStunServer];
    [self.iceServers addObject:defaultTurnServer];

    
//        [self.iceServers addObject:defaultStunServer3];
//        [self.iceServers addObject:defaultStunServer4];
//        [self.iceServers addObject:defaultStunServer5];
//        [self.iceServers addObject:defaultStunServer6];
//        [self.iceServers addObject:defaultStunServer7];
//        [self.iceServers addObject:defaultStunServer8];
//        [self.iceServers addObject:defaultStunServer9];
//        [self.iceServers addObject:defaultStunServer10];
//        [self.iceServers addObject:defaultStunServer11];
//        [self.iceServers addObject:defaultStunServer12];
    
   // [self.iceServers addObject:defaultTurnnServer12];
   // [self.iceServers addObject:defaultTurnnServer13];
   // [self.iceServers addObject:defaultTurnnServer14];
   // [self.iceServers addObject:defaultTurnnServer15];
    
    
    // [RTCPeerConnectionFactory initializeSSL];
    
    
    [self _createLocalStream];
}



- (void)_createLocalStream
{
//    self.localMediaStream = [self.peerFactory mediaStreamWithLabel:[[NSUUID UUID] UUIDString]];
    self.localMediaStream = [self.peerFactory mediaStreamWithLabel:@"iPhone"];
    
    RTCAudioTrack *audioTrack = [self.peerFactory audioTrackWithID:@"io"];
    
    
    [self.localMediaStream addAudioTrack:audioTrack];


    if (self.allowVideo)
    {
        RTCAVFoundationVideoSource *videoSource = [[RTCAVFoundationVideoSource alloc] initWithFactory:self.peerFactory constraints:nil];
        videoSource.useBackCamera = NO;
        RTCVideoTrack *videoTrack = [[RTCVideoTrack alloc] initWithFactory:self.peerFactory source:videoSource trackId:[[NSUUID UUID] UUIDString]];
        [self.localMediaStream addVideoTrack:videoTrack];
    }
}

//-(void)addAudioTrack
//{
//    self.localMediaStream = [self.peerFactory mediaStreamWithLabel:@"myAudioStream"];
//
//    RTCAudioTrack* audioTarck = [self.peerFactory audioTrackWithID:@"audio0"];
//
//    [self.localMediaStream addAudioTrack:audioTarck];
//
//    //[self.peer addStream:localStream];
//}
//-(RTCMediaStream*)createLocalMediaStream
//{
//    RTCMediaStream* localStream = [self.peerFactory mediaStreamWithLabel:@"ARDAMS"];
//
//        RTCVideoTrack* localVideoTrack;
////        localVideoTrack = [self createLocalVideoTrack];
//
//
//
//    [localStream addAudioTrack:[self.peerFactory audioTrackWithID:@"ARDAMSa0"]];
//    return localStream;
//}


- (RTCMediaConstraints *)_mediaConstraints
{
    RTCPair *audioConstraint = [[RTCPair alloc] initWithKey:@"OfferToReceiveAudio" value:@"true"];
    RTCPair *videoConstraint = [[RTCPair alloc] initWithKey:@"OfferToReceiveVideo" value:self.allowVideo ? @"true" : @"false"];
    RTCPair *sctpConstraint = [[RTCPair alloc] initWithKey:@"internalSctpDataChannels" value:@"true"];
    RTCPair *dtlsConstraint = [[RTCPair alloc] initWithKey:@"DtlsSrtpKeyAgreement" value:@"true"];

    return [[RTCMediaConstraints alloc] initWithMandatoryConstraints:@[audioConstraint, videoConstraint] optionalConstraints:@[sctpConstraint, dtlsConstraint]];
}

#pragma mark - ICE server

- (void)addICEServer:(RTCICEServer *)server
{
    BOOL isStun = [server.URI.scheme isEqualToString:@"stun"];
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

#pragma mark - Peer Connections

- (NSString *)identifierForPeer:(RTCPeerConnection *)peer
{
    NSArray *keys = [self.peerConnections allKeysForObject:peer];
    return (keys.count == 0) ? nil : keys[0];
}

- (void)addPeerConnectionForID:(NSString *)identifier
{
    RTCPeerConnection *peer = [self.peerFactory peerConnectionWithICEServers:[self iceServers] constraints:[self _mediaConstraints] delegate:self];
    [peer addStream:self.localMediaStream];
    peer.delegate = self;
    
//        DataChannelInit = [[RTCDataChannelInit alloc] init];
//        DataChannelInit.maxRetransmits = 0;
//        DataChannelInit.isOrdered=false;
//        DataChannelInit.maxRetransmitTimeMs = -1;
//        DataChannelInit.isNegotiated = false;
//        DataChannelInit.streamId = 25;
//        RTCDataChannel *dataChannel =[peer createDataChannelWithLabel:@"commands" config:DataChannelInit];
//        dataChannel.delegate = self;

    [self.peerConnections setObject:peer forKey:identifier];
}

- (void)removePeerConnectionForID:(NSString *)identifier
{
    RTCPeerConnection* peer = self.peerConnections[identifier];
    [self.peerConnections removeObjectForKey:identifier];
    [self.peerToRoleMap removeObjectForKey:identifier];
    [peer close];
}

#pragma mark -

- (void)createOfferForPeerWithID:(NSString *)peerID
{
//    RTCPeerConnection *peerConnection = [self.peerConnections objectForKey:peerID];
//
//    [self.peerToRoleMap setObject:TLKPeerConnectionRoleInitiator forKey:peerID];
//    [peerConnection createOfferWithDelegate:self constraints:[self _mediaConstraints]];
    
    
//    RTCDataChannelInit *DataChannelInit = [[RTCDataChannelInit alloc] init];
//    DataChannelInit.maxRetransmits = 0;
//    DataChannelInit.isOrdered=false;
//    DataChannelInit.maxRetransmitTimeMs = -1;
//    DataChannelInit.isNegotiated = false;
//    DataChannelInit.streamId = 25;
//    RTCDataChannel *dataChannel =[peerConnection createDataChannelWithLabel:@"commands" config:DataChannelInit];
//    dataChannel.delegate = self;
   // self.datachannel = dataChannel;
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

- (void)addICECandidate:(RTCICECandidate*)candidate forPeerWithID:(NSString *)peerID
{
    RTCPeerConnection *peerConnection = [self.peerConnections objectForKey:peerID];
    
    if (peerConnection.iceGatheringState == RTCICEGatheringNew)
    {
        NSMutableArray *candidates = [self.peerToICEMap objectForKey:peerID];
        
        if (!candidates)// if nil initialise and add
        {
            candidates = [NSMutableArray array];
            [self.peerToICEMap setObject:candidates forKey:peerID];
        }
        
        [candidates addObject:candidate];
        
    }
    else
    {
        [peerConnection addICECandidate:candidate];
    }
}

#pragma mark - RTCSessionDescriptionDelegate

// Note: all these delegate calls come back on a random background thread inside WebRTC,
// so all are bridged across to the main thread

- (void)peerConnection:(RTCPeerConnection *)peerConnection didCreateSessionDescription:(RTCSessionDescription *)sdp error:(NSError *)error
{
//    dispatch_async(dispatch_get_main_queue(), ^{
        RTCSessionDescription* sessionDescription = [[RTCSessionDescription alloc] initWithType:sdp.type sdp:sdp.description];
        [peerConnection setLocalDescriptionWithDelegate:self sessionDescription:sessionDescription];
//    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didSetSessionDescriptionWithError:(NSError *)error
{
    NSLog(@"error=%@",error.localizedDescription);
    
//    dispatch_async(dispatch_get_main_queue(), ^{
        if (peerConnection.iceGatheringState == RTCICEGatheringGathering)
        {
            NSArray *keys = [self.peerConnections allKeysForObject:peerConnection];
            
            if ([keys count] > 0)
            {
                NSArray *candidates = [self.peerToICEMap objectForKey:keys[0]];
                
                for (RTCICECandidate* candidate in candidates)
                {
                    [peerConnection addICECandidate:candidate];
                }
                [self.peerToICEMap removeObjectForKey:keys[0]];
            }
        }

        if (peerConnection.signalingState == RTCSignalingHaveLocalOffer)
        {
            NSArray *keys = [self.peerConnections allKeysForObject:peerConnection];
            if ([keys count] > 0)
            {
//                [[APIManager sharedManager] sendSDPUsername:keys[0] SDP:peerConnection.localDescription];

                //[self.delegate webRTC:self didSendSDPOffer:peerConnection.localDescription forPeerWithID:keys[0]];
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
//                    [[APIManager sharedManager] sendSDPUsername:keys[0] SDP:peerConnection.localDescription];
                    
                   // [self.delegate webRTC:self didSendSDPAnswer:peerConnection.localDescription forPeerWithID:keys[0]];
                }
            }
        }
  // });
}

#pragma mark - String utilities

- (NSString *)stringForSignalingState:(RTCSignalingState)state
{
    NSString *signalingStateString = nil;
    switch (state) {
        case RTCSignalingStable:
            signalingStateString = @"Stable";
            NSLog(@"Signalling State = Stable");
            break;
        case RTCSignalingHaveLocalOffer:
            signalingStateString = @"Have Local Offer";
            NSLog(@"Signalling State = Have Local Offer");
            break;
        case RTCSignalingHaveRemoteOffer:
            signalingStateString = @"Have Remote Offer";
            NSLog(@"Signalling State = Have Remote Offer");

            break;
        case RTCSignalingClosed:
            signalingStateString = @"Closed";
            NSLog(@"Signalling State = Closed");

            break;
        default:
            signalingStateString = @"Other state";
            NSLog(@"Signalling State = Other state");

            break;
    }

    return signalingStateString;
}

- (NSString *)stringForConnectionState:(RTCICEConnectionState)state
{
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

- (NSString *)stringForGatheringState:(RTCICEGatheringState)state
{
    NSString *gatheringState = nil;
    switch (state) {
        case RTCICEGatheringNew:
            gatheringState = @"New";
            NSLog(@"ICE Current State = new");
            break;
            
        case RTCICEGatheringGathering:
            gatheringState = @"Gathering";
            NSLog(@"ICE Current State = Gathering");
            break;
            
        case RTCICEGatheringComplete:
            gatheringState = @"Complete";
            NSLog(@"ICE Current State = Complete");
            break;
            
        default:
            gatheringState = @"Other state";
            NSLog(@"ICE Current State = Other state");
            break;
            
    }
    return gatheringState;
}

#pragma mark - RTCPeerConnectionDelegate

// Note: all these delegate calls come back on a random background thread inside WebRTC,
// so all are bridged across to the main thread

- (void)peerConnectionOnError:(RTCPeerConnection *)peerConnection
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//    });
    NSLog(@"error = %@",peerConnection);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection signalingStateChanged:(RTCSignalingState)stateChanged
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"signal state = %d",peerConnection.signalingState);

        // I'm seeing this, but not sure what to do with it yet
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection addedStream:(RTCMediaStream *)stream
{
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.delegate webRTC:self addedStream:stream forPeerWithID:[self identifierForPeer:peerConnection]];
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection removedStream:(RTCMediaStream *)stream
{
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.delegate webRTC:self removedStream:stream forPeerWithID:[self identifierForPeer:peerConnection]];
//        
        
            });
}

- (void)peerConnectionOnRenegotiationNeeded:(RTCPeerConnection *)peerConnection
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //    [self.peerConnection createOfferWithDelegate:self constraints:[self mediaConstraints]];
        // Is this delegate called when creating a PC that is going to *receive* an offer and return an answer?
        
        NSLog(@"peerConnectionOnRenegotiationNeeded ?");
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection iceConnectionChanged:(RTCICEConnectionState)newState
{

//    dispatch_async(dispatch_get_main_queue(), ^{
    
        NSLog(@"peerConnection iceGatheringChanged?");
        
        NSLog(@"Connection state = %d",peerConnection.iceConnectionState);
        
        
//    });
}




- (void)peerConnection:(RTCPeerConnection *)peerConnection iceGatheringChanged:(RTCICEGatheringState)newState
{
    NSString *gatheringState = nil;
    switch (newState) {
        case RTCICEGatheringNew:
            gatheringState = @"New";
            NSLog(@"ICE State changed = new");
            break;
        case RTCICEGatheringGathering:
            gatheringState = @"Gathering";
            NSLog(@"ICE State changed = Gathering");

            break;
        case RTCICEGatheringComplete:
            gatheringState = @"Complete";
            NSLog(@"ICE State changed = complete");

            break;
        default:
            gatheringState = @"Other state";
            NSLog(@"ICE State changed = Other state");

            break;
    }
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection gotICECandidate:(RTCICECandidate *)candidate
{
//    dispatch_async(dispatch_get_main_queue(), ^{

        NSLog(@"MyCandidate = %@",candidate);
        
        NSMutableDictionary* dic = [NSMutableDictionary new];
        [dic setObject:peerConnection forKey:@"connection"];
        [dic setObject:candidate forKey:@"candidate"];
        [self sendCandidateToServer:dic];
        //[self performSelector:@selector(sendCandidateToServer:) withObject:(dic) afterDelay:5.0];

//    });
}


-(void) sendCandidateToServer:(NSDictionary*)dic
{

    RTCPeerConnection* peerConnection = [dic objectForKey:@"connection"];
    RTCICECandidate* candidate = [dic objectForKey:@"candidate"];
    NSArray* keys = [self.peerConnections allKeysForObject:peerConnection];
    if ([keys count] > 0)
    {
        
        //  [self.delegate webRTC:self didSendICECandidate:candidate forPeerWithID:keys[0]];
        
        
        
        
        
        
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
        [[APIManager sharedManager] sendCandidateUsername:keys[0] candidate:json1];
        
        
    }

}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didOpenDataChannel:(RTCDataChannel *)dataChannel
{
    dispatch_async(dispatch_get_main_queue(), ^{
        int fd = dataChannel.streamId;
//        RTCDataBuffer* buffer = [RTCDataBuffer alloc] initWithData:<#(NSData *)#> isBinary:<#(BOOL)#>
//        dataChannel sendData:<#(RTCDataBuffer *)#>
        NSLog(@"peerConnection didOpenDataChannel?");
    });
}

-(void)channelDidChangeState:(RTCDataChannel *)channel
{

}


-(void)channel:(RTCDataChannel *)channel didReceiveMessageWithBuffer:(RTCDataBuffer *)buffer
{

}


-(void) initDataChannel:(NSString*)peerID
{
    RTCPeerConnection *peerConnection = [self.peerConnections objectForKey:peerID];

    RTCDataChannelInit *DataChannelInit = [[RTCDataChannelInit alloc] init];
    DataChannelInit.maxRetransmits = 0;
    DataChannelInit.isOrdered=false;
    DataChannelInit.maxRetransmitTimeMs = -1;
    DataChannelInit.isNegotiated = false;
    DataChannelInit.streamId = 25;
    RTCDataChannel *dataChannel =[peerConnection createDataChannelWithLabel:@"commands" config:DataChannelInit];
    dataChannel.delegate=self;
    self.dataChannel = dataChannel;
}

- (void) sendDataToRemote:(NSString*)message peerId:(NSString*)peerID
{
    NSData *newData = [message dataUsingEncoding:NSUTF8StringEncoding];
    RTCDataBuffer *dataBuff = [[RTCDataBuffer alloc] initWithData:newData isBinary:true];
    BOOL bDataSent = [self.dataChannel sendData:dataBuff];
    NSLog(@"Data sent = %d", bDataSent);
}
@end
