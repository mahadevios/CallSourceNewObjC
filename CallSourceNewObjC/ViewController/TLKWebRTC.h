//
//  TLKWebRTC.h
//  Copyright (c) 2014 &yet, LLC and TLKWebRTC contributors
//

#import <Foundation/Foundation.h>

#import <WebRTC/WebRTC.h>

@class ICEServers;

@class AVCaptureDevice;

@protocol TLKWebRTCDelegate;

@interface TLKWebRTC : NSObject

@property (nonatomic, weak) id <TLKWebRTCDelegate> delegate;

- (instancetype)initWithVideoDevice:(AVCaptureDevice *)device;
- (instancetype)initWithVideo:(BOOL)allowVideo;

@property (readwrite, nonatomic) RTCMediaStream *localMediaStream;
@property (nonatomic, strong) RTCPeerConnectionFactory *peerFactory;
@property (nonatomic,strong) RTCDataChannel* dataChannelRemote;
@property (nonatomic, strong) NSMutableDictionary *peerConnections;
@property (nonatomic, strong) NSMutableDictionary *peerToRoleMap;
@property (nonatomic, strong) NSMutableDictionary *peerToICEMap;
@property (nonatomic) BOOL allowVideo;
@property (nonatomic, strong) AVCaptureDevice *videoDevice;
@property (nonatomic, strong) NSMutableArray *iceServers;

@property(nonatomic,strong) NSMutableArray* iceCandidateDictArray;
@property(nonatomic,strong) NSMutableArray* iceCandidateGotFromServerArray;
@property(nonatomic,strong) NSMutableArray* XIRiceServerArray;
//@property(nonatomic,strong) NSMutableArray* cachedCandidateToSendArray;
@property(nonatomic,strong) NSString* calleeName;
@property(nonatomic,strong) NSString* sdpSender;
@property(nonatomic,strong) RTCDataChannel* dataChannel;
@property(nonatomic,strong) RTCVideoTrack *videoTrack;
@property(nonatomic,strong) RTCVideoSource *videoSource;
@property(nonatomic,strong) RTCCameraVideoCapturer * capt;
@property(nonatomic,strong) RTCEAGLVideoView *renderView;

- (void)addPeerConnectionForID:(NSString *)identifier iceServerArray:(NSMutableArray*)iceServerArray;
- (void)removePeerConnectionForID:(NSString *)identifier;

- (void)createOfferForPeerWithID:(NSString *)peerID calleeName:(NSString*)calleeName;
- (void)setRemoteDescription:(RTCSessionDescription *)remoteSDP forPeerWithID:(NSString *)peerID receiver:(BOOL)isReceiver;
- (void)addICECandidate:(RTCIceCandidate *)candidate forPeerWithID:(NSString *)peerID;

// Add a STUN or TURN server, adding a STUN server replaces the previous STUN server, adding a TURN server appends it to the list
- (void)addICEServer:(RTCIceServer *)server;

// The WebRTC stream captured locally that will be sent to peers, useful for displaying a preview of the local camera
// in an RTCVideoRenderer and muting or blacking out th stream sent to peers
//@property (readonly, nonatomic) RTCMediaStream *localMediaStream;

@end

// WebRTC signal delegate protocol
@protocol TLKWebRTCDelegate <NSObject>
@required
-(void)webRTC:(TLKWebRTC*)tlk didSendSDPOffer:(NSString*)localDescription forPeerWithID:(NSString*)peerId calleeUser:(NSString*)calleeUser allowVideo:(NSString*)allowVideo;
- (void)webRTC:(TLKWebRTC *)webRTC didSendSDPAnswer:(NSString *)answer forPeerWithID:(NSString* )peerID calleeUser:(NSString*)calleeUser allowVideo:(NSString*)allowVideo;
- (void)webRTC:(TLKWebRTC *)webRTC didSendICECandidate:(RTCIceCandidate *)candidate forPeerWithID:(NSString *)peerID allowVideo:(NSString*)allowVideo;
- (void)webRTC:(TLKWebRTC *)webRTC didObserveICEConnectionStateChange:(RTCIceConnectionState)state forPeerWithID:(NSString *)peerID;
//- (void)webRTC:(TLKWebRTC *)webRTC sendCachedICECandidate:(NSMutableArray *)candidateArray forPeerWithID:(NSString *)peerID;
- (void)webRTC:(TLKWebRTC *)webRTC addedStream:(RTCMediaStream *)stream forPeerWithID:(NSString *)peerID;
- (void)webRTC:(TLKWebRTC *)webRTC removedStream:(RTCMediaStream *)stream forPeerWithID:(NSString *)peerID;
- (void)peerConnection:(TLKWebRTC* )webRTC peerConnection:(RTCPeerConnection *)peerConnection openedDataChannel:(RTCDataChannel *)dataChannel;
@end
