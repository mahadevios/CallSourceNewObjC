//
//  TLKWebRTC.h
//  Copyright (c) 2014 &yet, LLC and TLKWebRTC contributors
//

#import <Foundation/Foundation.h>

#import "RTCSessionDescription.h"
#import "RTCICECandidate.h"
#import "RTCMediaStream.h"
#import "RTCTypes.h"
#import "RTCDataChannel.h"
#import <AVFoundation/AVFoundation.h>

@class RTCICEServer;

@class AVCaptureDevice;


@interface WebRTC : NSObject<RTCDataChannelDelegate>
{
    RTCDataChannelInit *DataChannelInit;
}
//@property (nonatomic, weak) id <WebRTCDelegate> delegate;
@property(nonatomic,strong) NSMutableArray* iceCandidateDictArray;
@property(nonatomic,strong) NSMutableArray* iceCandidateGotFromServerArray;
@property(nonatomic, strong) RTCDataChannel *dataChannel;

- (instancetype)initWithVideoDevice:(AVCaptureDevice *)device;
- (instancetype)initWithVideo:(BOOL)allowVideo;

- (void)addPeerConnectionForID:(NSString *)identifier;
- (void)removePeerConnectionForID:(NSString *)identifier;

- (void)createOfferForPeerWithID:(NSString *)peerID;
- (void)setRemoteDescription:(RTCSessionDescription *)remoteSDP forPeerWithID:(NSString *)peerID receiver:(BOOL)isReceiver;
- (void)addICECandidate:(RTCICECandidate *)candidate forPeerWithID:(NSString *)peerID;
- (void) sendDataToRemote:(NSString*)message peerId:(NSString*)peerID;
// Add a STUN or TURN server, adding a STUN server replaces the previous STUN server, adding a TURN server appends it to the list
- (void)addICEServer:(RTCICEServer *)server;
- (void) initDataChannel:(NSString*)peerID;
// The WebRTC stream captured locally that will be sent to peers, useful for displaying a preview of the local camera
// in an RTCVideoRenderer and muting or blacking out th stream sent to peers
@property (readonly, nonatomic) RTCMediaStream *localMediaStream;

@end

// WebRTC signal delegate protocol
@protocol TLKWebRTCDelegate <NSObject>
@required
- (void)webRTC:(WebRTC *)webRTC didSendSDPOffer:(RTCSessionDescription *)offer forPeerWithID:(NSString *)peerID;
- (void)webRTC:(WebRTC *)webRTC didSendSDPAnswer:(RTCSessionDescription *)answer forPeerWithID:(NSString* )peerID;
- (void)webRTC:(WebRTC *)webRTC didSendICECandidate:(RTCICECandidate *)candidate forPeerWithID:(NSString *)peerID;
- (void)webRTC:(WebRTC *)webRTC didObserveICEConnectionStateChange:(RTCICEConnectionState)state forPeerWithID:(NSString *)peerID;

- (void)webRTC:(WebRTC *)webRTC addedStream:(RTCMediaStream *)stream forPeerWithID:(NSString *)peerID;
- (void)webRTC:(WebRTC *)webRTC removedStream:(RTCMediaStream *)stream forPeerWithID:(NSString *)peerID;
@end
