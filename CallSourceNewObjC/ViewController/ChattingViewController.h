//
//  ChattingViewController.h
//  CallSourceNewObjC
//
//  Created by mac on 22/03/18.
//  Copyright © 2018 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebRTC/WebRTC.h>

@interface ChattingViewController : UIViewController<RTCDataChannelDelegate,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>

@property(nonatomic,strong) RTCPeerConnection* peerConnection;
@property(nonatomic,strong) NSMutableArray* messagesArray;
@property(nonatomic,strong) NSString* connectedPeerName;
@property(nonatomic,strong) NSString* callerName;
@property(nonatomic,strong) RTCDataChannel* dataChannel;
@property(nonatomic,strong) RTCEAGLVideoView *renderView;
@property(nonatomic,strong) RTCMediaStream* mediaStream;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextViewBottonDistConstraint;
@property(nonatomic, strong) NSNotification* notification;
@property(nonatomic) double movement;
@property (weak, nonatomic) IBOutlet UITextField *chattextField;

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)sendButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *navigationBarTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *sendTextView;
- (IBAction)attachmentButtonClicked:(id)sender;
- (IBAction)sendMessageButtonCLlked:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *navigationView;

-(void)setDataChannelAnddelegate:(RTCDataChannel *)dataChannel;
-(void)addVideoView:(RTCEAGLVideoView*)renderView mediaStream:(RTCMediaStream*)mediaStream;

@end
