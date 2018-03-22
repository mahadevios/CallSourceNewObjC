//
//  ViewController.h
//  CallSourceNewObjC
//
//  Created by mac on 05/10/17.
//  Copyright © 2017 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "RTCNSGLVideoView.h"

//#import "RTCDispatcher.h"
//#import <WebRTC/RTCMacros.h>
#import <AVFoundation/AVFoundation.h>


#import "TLKWebRTC.h"

@interface ViewController : UIViewController<TLKWebRTCDelegate>

@property(nonatomic,strong) RTCPeerConnectionFactory* factory;
@property(nonatomic,strong) RTCPeerConnection* peerConn;
@property(nonatomic,strong) NSString* SDP;
@property(nonatomic,strong) NSString* currentUser;
@property(nonatomic,strong) NSMutableArray* iceCandidateArray;
@property(nonatomic,strong) NSMutableArray* iceCandidateDictArray;
@property(nonatomic,strong) NSMutableArray* iceCandidateGotFromServerArray;
@property(nonatomic,strong) NSString* calleName;

@property(nonatomic,strong) TLKWebRTC* tlk;

@property(nonatomic,strong) NSMutableArray* serverCredArray;
//@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (weak, nonatomic) IBOutlet UIButton *audioCallButton;

- (IBAction)registerButtonClicked:(id)sender;
- (IBAction)initPeerButtonClicked:(id)sender;
- (IBAction)createOfferClicked:(id)sender;
- (IBAction)commonSetupButtonClicked:(id)sender;
- (IBAction)initOfferButtonClicked:(id)sender;
- (IBAction)sendMessageButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextFIeld;
- (IBAction)resetButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *callStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *welcomeUserLabel;
@end

