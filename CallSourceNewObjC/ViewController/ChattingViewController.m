//
//  ChattingViewController.m
//  CallSourceNewObjC
//
//  Created by mac on 22/03/18.
//  Copyright © 2018 Xanadutec. All rights reserved.
//

#import "ChattingViewController.h"

@interface ChattingViewController ()


@end

@implementation ChattingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.messagesArray = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationBarTitleLabel.text = [NSString stringWithFormat:@"Connected with %@", self.connectedPeerName];

    [self.mediaStream.videoTracks.lastObject addRenderer:self.renderView];
    
    self.renderView.frame = CGRectMake(self.view.frame.size.width*0.75 , self.chattextField.frame.origin.y+self.chattextField.frame.size.height+20, self.view.frame.size.width*0.23, self.view.frame.size.width*0.23);
    
    [self.view addSubview:self.renderView];
}
- (void)keyboardWasShown:(NSNotification *)notification
{
    
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //Given size may not account for screen rotation
    self.keyboardHeight = MIN(keyboardSize.height,keyboardSize.width);
    
    self.tableViewHeight.constant = self.tableViewHeight.constant - self.keyboardHeight;
//    int width = MAX(keyboardSize.height,keyboardSize.width);
    
    //your other code here..........
}


-(void)dataChannelDidChangeState:(RTCDataChannel *)dataChannel
{
    NSLog(@"data channel state = %d", dataChannel.readyState);
    
}

-(void)dataChannel:(RTCDataChannel *)dataChannel didReceiveMessageWithBuffer:(RTCDataBuffer *)buffer
{
    NSString* newMessage = [[NSString alloc] initWithData:buffer.data encoding:NSUTF8StringEncoding];
    
    if (self.dataChannel == nil)
    {
        self.dataChannel = dataChannel;
        
        self.dataChannel.delegate = self;
    }
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    
    [dic setObject:newMessage forKey:self.connectedPeerName];
    
    [self.messagesArray addObject:dic];
    
    NSLog(@"new message = %@ ", newMessage);
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self.tableView reloadData];
                       
                       self.chattextField.text = @"";

                   });
//    [self sendMessageUsingDataChannel:@"reply"];
}

-(void)sendMessageUsingDataChannel:(NSString*)messageString
{
    RTCDataBuffer *buffer = [[RTCDataBuffer alloc] initWithData:[messageString dataUsingEncoding:NSUTF8StringEncoding] isBinary:NO];
    
    BOOL messageSent = [self.dataChannel sendData:buffer];
    
    if (messageSent)
    {
        NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];

        [dic setObject:messageString forKey:@"You"];
        
        [self.messagesArray addObject:dic];
    }
    NSLog(@"data sent %d", messageSent);
    
    [self.tableView reloadData];
    
    self.chattextField.text = @"";
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messagesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    UILabel* userNameLabel = [cell viewWithTag:101];
    
    UILabel* messageLabel = [cell viewWithTag:102];
    
//    messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
//    messageLabel.numberOfLines = 0;
//    messageLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    
    
   

    NSMutableDictionary* dic = [self.messagesArray objectAtIndex:indexPath.row];
    
    NSString* message = [dic objectForKey:@"You"];
    
    if (message == nil)
    {
        message = [dic objectForKey:self.connectedPeerName];

        userNameLabel.text = self.connectedPeerName;
        
        messageLabel.text = message;
    }
    else
    {
       userNameLabel.text = @"You";
        
       messageLabel.text = message;
    }
    NSString *cellText = message;

    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    UILabel* userNameLabel = [cell viewWithTag:101];
    
    UILabel* messageLabel = [cell viewWithTag:102];
    
    NSMutableDictionary* dic = [self.messagesArray objectAtIndex:indexPath.row];
    
    NSString* message = [dic objectForKey:@"You"];
    
    UIFont *cellFont = messageLabel.font;

    if (message == nil)
    {
        message = [dic objectForKey:self.connectedPeerName];
        
        userNameLabel.text = self.connectedPeerName;
        
        messageLabel.text = message;
    }
    else
    {
        userNameLabel.text = @"You";
        
        messageLabel.text = message;
    }
    
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    
    CGSize labelSize = [message sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    
    return labelSize.height + 50;
    
    
}

-(void)setDataChannelAnddelegate:(RTCDataChannel *)dataChannel
{
    self.dataChannel = dataChannel;
    
    self.dataChannel.delegate = self;
}

-(void)addVideoView:(RTCEAGLVideoView*)renderView mediaStream:(RTCMediaStream*)mediaStream
{
    self.renderView = renderView;
    
    self.mediaStream = mediaStream;
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backButtonPressed:(id)sender
{
    
}

- (IBAction)sendButtonClicked:(id)sender
{
    [self sendMessageUsingDataChannel:self.chattextField.text];
}
@end
