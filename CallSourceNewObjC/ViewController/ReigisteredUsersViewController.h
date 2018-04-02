//
//  ReigisteredUsersViewController.h
//  CallSourceNewObjC
//
//  Created by mac on 10/03/18.
//  Copyright © 2018 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProviderDelegate.h"
#import <WebRTC/WebRTC.h>
#import "ChattingViewController.h"
#import "TLKWebRTC.h"
#import "AppDelegate.h"

@interface ReigisteredUsersViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) NSMutableArray* registeredUserArray;
@property(nonatomic,strong) NSMutableArray* serverCredArray;
@property(nonatomic,strong) NSString* calleName;
@property(nonatomic,strong) ChattingViewController* chatViewController;
@property(nonatomic,strong) RTCDataChannel* dataChannel;
@property(nonatomic,strong) RTCEAGLVideoView *renderView;
@property(nonatomic) BOOL isChatViewPresented;
@property(nonatomic, strong) MBProgressHUD* hud;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *navigationHedingLabel;
@property(nonatomic,strong) ProviderDelegate* providerDelegate;
@property (weak, nonatomic) IBOutlet UILabel *callStatusLabel;
- (IBAction)logoutButtonClicked:(id)sender;
- (IBAction)startChattingButtonClicked:(id)sender;
@property(nonatomic,strong) TLKWebRTC* tlk;
@property(nonatomic,strong) AppDelegate* app;
@end
