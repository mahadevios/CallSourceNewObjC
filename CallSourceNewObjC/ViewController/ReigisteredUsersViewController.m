//
//  ReigisteredUsersViewController.m
//  CallSourceNewObjC
//
//  Created by mac on 10/03/18.
//  Copyright © 2018 Xanadutec. All rights reserved.
//

#import "ReigisteredUsersViewController.h"

#import "ViewController.h"

#import "AppDelegate.h"


@interface ReigisteredUsersViewController ()

@end

@implementation ReigisteredUsersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getListOfRegisteredUser:) name:NOTIFICATION_GET_LISTOF_REGISTERED_USER
                                               object:nil];
    
    self.registeredUserArray = [NSMutableArray new];

    NSString* loggedInUser = [[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_USER];
    
    [[APIManager sharedManager] getListOfRegisteredUser:loggedInUser];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setICEServersGotFromXIR:) name:NOTIFICATION_GOT_TURN
                                                   object:nil];
    

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(connectionChanged:) name:NOTIFICATION_RTC_COONECTION_CHANGED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataChannelOpened:) name:NOTIFICATION_DATA_CHANNEL_OPENED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newStreamAdded:) name:NOTIFICATION_NEW_STREAM_RECEIVED
                                               object:nil];
//    [[APIManager sharedManager] getICECredentials];
    // Do any additional setup after loading the view.
}

-(void)connectionChanged:(NSNotification*) notification
{
    NSDictionary* notiDict = notification.object;
    
    NSString* connState = [notiDict valueForKey:@"ConnectionState"];
    
    NSString* connectedUserName = [notiDict objectForKey:@"ConnectedPeerName"];

    RTCDataChannel* dataChannel = [notiDict objectForKey:@"DataChannel"];

    NSString* currentUser = [[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_USER];
    
    if ([connState intValue] == RTCIceConnectionStateConnected)
    {
//        self.providerDelegate = [[ProviderDelegate alloc] init];
        
//        NSUUID* uuid = [NSUUID UUID];
        
        if (!self.isChatViewPresented)
        {
            self.callStatusLabel.text = [NSString stringWithFormat:@"Connected with %@", connectedUserName];
            
            if (self.vc == nil)
            {
                self.vc =  [self.storyboard instantiateViewControllerWithIdentifier:@"ChattingViewController"];

            }
            
            self.vc.connectedPeerName = connectedUserName;
            
            //        self.dataChannel.delegate = vc;
        
            [self.vc setDataChannelAnddelegate:dataChannel];
            
            self.isChatViewPresented = true;
            
            self.vc.callerName = currentUser;
            
            [self presentViewController:self.vc animated:true completion:nil];
            
        
        }
        
        
//        [self.providerDelegate displayIncomingCall:uuid handle:@"handle" hasVideo:NO withCompletion:nil];
        
        //self.callStatusLabel.text = [NSString stringWithFormat:@"Connected to %@",self.calleName];
        
    }
    else
        if ([connState intValue] == RTCIceConnectionStateFailed || [connState intValue] == RTCIceConnectionStateDisconnected)

        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HANG_UP_CALL object:nil];
            
            self.callStatusLabel.text = [NSString stringWithFormat:@"Select a user to make a call"];


            //self.callStatusLabel.text = [NSString stringWithFormat:@"Failed to connect %@",self.calleName];
        }
}

-(void)dataChannelOpened:(NSNotification*)noti
{

    NSDictionary* dict = noti.object;
    
    RTCDataChannel* dataChannel = [dict objectForKey:@"DataChannel"];
    
    if (self.vc == nil)
    {
        self.vc =  [self.storyboard instantiateViewControllerWithIdentifier:@"ChattingViewController"];
        
    }
    
    [self.vc setDataChannelAnddelegate:dataChannel];
    
}


-(void)newStreamAdded:(NSNotification*)noti
{
    NSDictionary* dict = noti.object;
    
    RTCMediaStream* mediaStream = [dict objectForKey:@"Stream"];
    
    NSArray* videoTrack = [mediaStream videoTracks];
    
    if (videoTrack.count > 0)
    {
        if (self.vc == nil)
        {
            self.vc =  [self.storyboard instantiateViewControllerWithIdentifier:@"ChattingViewController"];
            
        }
        
//        self.renderView = [[RTCEAGLVideoView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/3, self.view.frame.size.height/3, self.view.frame.size.width/3, self.view.frame.size.height/3)];
        self.renderView = [[RTCEAGLVideoView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];

        
        
        [self.vc addVideoView:self.renderView mediaStream:mediaStream];
//        [mediaStream.videoTracks.lastObject addRenderer:self.renderView];
    }
    

}
//-(void)connectionChanged:(NSNotification*) notification
//{
//    NSString* connectionState = notification.object;
//
//    if ([connectionState isEqualToString:@"Connected"])
//    {
//        self.providerDelegate = [[ProviderDelegate alloc] init];
//
//        NSUUID* uuid = [NSUUID UUID];
//
//        [self.providerDelegate displayIncomingCall:uuid handle:@"handle" hasVideo:NO withCompletion:nil];
//
//        //self.callStatusLabel.text = [NSString stringWithFormat:@"Connected to %@",self.calleName];
//
//    }
//    else
//    if ([connectionState isEqualToString:@"DisConnectedOrFailed"])
//
//    {
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HANG_UP_CALL object:nil];
//
//        //self.callStatusLabel.text = [NSString stringWithFormat:@"Failed to connect %@",self.calleName];
//    }
//}


-(void) setICEServersGotFromXIR:(NSNotification *)notification
{
    NSDictionary* dic = notification.object;
    
    NSDictionary* vDict = [dic objectForKey:@"v"];
    
    NSArray* iceServersDict = [vDict valueForKey:@"iceServers"];
    
    self.serverCredArray = [NSMutableArray new];
    
    for (NSDictionary* serverCredDict in iceServersDict)
    {
        [self.serverCredArray addObject:serverCredDict];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    
    NSString* currentUser = [[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_USER];
    
    _navigationHedingLabel.text = [NSString stringWithFormat:@"Welcome %@",currentUser];
    
}
-(void)getListOfRegisteredUser:(NSNotification*)notification
{
    
    NSDictionary* dic = notification.object;
    
    NSString* registeredUser = [dic valueForKey:@"registeredUser"];
    
    NSData* data = [registeredUser dataUsingEncoding:NSUTF8StringEncoding];
    
    NSArray* registeredUserArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    for (NSDictionary* userDic in registeredUserArray)
    {
        NSString* username = [userDic valueForKey:@"userName"];
        
        [self.registeredUserArray addObject:username];
    }
    
    [self.tableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.registeredUserArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    UILabel* userNameLabel = [cell viewWithTag:101];
    
    UIButton* audioCallButton = [cell viewWithTag:102];
    
    UIButton* videoCallButton = [cell viewWithTag:103];
    
    audioCallButton.tag = indexPath.row;
    
    videoCallButton.tag = indexPath.row;
    
    [audioCallButton addTarget:self action:@selector(audioCallButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [videoCallButton addTarget:self action:@selector(videoCallButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    userNameLabel.text = [NSString stringWithFormat:@"%@",[self.registeredUserArray objectAtIndex:indexPath.row]];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UILabel* userNameLabel = [cell viewWithTag:101];
    
    
//    ViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
//
//    vc.calleName = userNameLabel.text;
//
//    vc.serverCredArray = self.serverCredArray;
//
//    [self presentViewController:vc animated:YES completion:nil];
    self.calleName = userNameLabel.text;
    
    self.callStatusLabel.text = [NSString stringWithFormat:@"Connecting to %@", self.calleName];
    
    [self startACall:userNameLabel.text allowVideo:false];
    
//    ChattingViewController* vc =  [self.storyboard instantiateViewControllerWithIdentifier:@"ChattingViewController"];
//
//    self.dataChannel.delegate = vc;
//
//    [self presentViewController:vc animated:true completion:nil];
    
}

-(void)audioCallButtonClicked:(UIButton*)sender
{
    NSString* calleName = [NSString stringWithFormat:@"%@",[self.registeredUserArray objectAtIndex:sender.tag]];

    self.calleName = calleName;
    
    self.callStatusLabel.text = [NSString stringWithFormat:@"Connecting to %@", self.calleName];
    
    [self startACall:self.calleName allowVideo:false];
}

-(void)videoCallButtonClicked:(UIButton*)sender
{
    NSString* calleName = [NSString stringWithFormat:@"%@",[self.registeredUserArray objectAtIndex:sender.tag]];
    
    self.calleName = calleName;
    
    self.callStatusLabel.text = [NSString stringWithFormat:@"Connecting to %@", self.calleName];
    
    [self startACall:self.calleName allowVideo:true];
}

-(void)startACall:(NSString*)calleName allowVideo:(BOOL)allowVideo
{
    AppDelegate* app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    app.tlk = [[TLKWebRTC alloc] initWithVideo:allowVideo];
    
    app.tlk.delegate = app;
    
    NSString* currentUser = [[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_USER];

    [app.tlk addPeerConnectionForID:currentUser iceServerArray:self.serverCredArray]; // create peer connection
    
//    [RTCAudioSession sharedInstance].useManualAudio = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:app.tlk
                                             selector:@selector(setSDPGotFromServer:) name:NOTIFICATION_GET_SDP
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:app.tlk
                                             selector:@selector(setCandidatesGotFromServer:) name:NOTIFICATION_GET_CANDIDATES
                                               object:nil];
    
    [app.tlk createOfferForPeerWithID:currentUser calleeName:calleName];  // create offer
    
//    self.callStatusLabel.hidden = NO;
    
//    self.callStatusLabel.text = [NSString stringWithFormat:@"Connecting to %@",self.calleName];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)logoutButtonClicked:(id)sender
{
    NSString* currentUser = [[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_USER];

    [[APIManager sharedManager] logoutUsername:currentUser];
}

- (IBAction)startChattingButtonClicked:(id)sender
{
//    ChattingViewController* vc =  [self.storyboard instantiateViewControllerWithIdentifier:@"ChattingViewController"];
//
//    self.dataChannel.delegate = vc;
//
//    [self presentViewController:vc animated:true completion:nil];
}
@end
