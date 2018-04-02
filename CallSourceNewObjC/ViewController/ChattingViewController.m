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
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWasShown:)
//                                                 name:UIKeyboardDidShowNotification
//                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissChatView:) name:NOTIFICATION_DISMISS_CHATVIEW
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.sendTextView.delegate = self;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationBarTitleLabel.text = [NSString stringWithFormat:@"Connected with %@", self.connectedPeerName];

    [self.mediaStream.videoTracks.lastObject addRenderer:self.renderView];
    
    self.renderView.frame = CGRectMake(self.view.frame.size.width*0.75 , self.navigationView.frame.origin.y+self.navigationView.frame.size.height+20, self.view.frame.size.width*0.23, self.view.frame.size.width*0.23);
    
    [self.view addSubview:self.renderView];
    
    self.sendTextView.layer.borderWidth = 1.0;
    
    self.sendTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.sendTextView.layer.cornerRadius = 4.0;
}

#pragma mark - Notification Selectors

-(void)dismissChatView:(NSNotification*)noti
{
    
    self.dataChannel = nil;
    
    self.dataChannel.delegate = nil;

    self.mediaStream = nil;
    
    self.renderView = nil;
    
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)keyboardWasShown:(NSNotification *)notification
{
    
    // Get the size of the keyboard.
//    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//
//    //Given size may not account for screen rotation
//    self.keyboardHeight = MIN(keyboardSize.height,keyboardSize.width);
//
//    self.tableViewHeight.constant = self.tableViewHeight.constant - self.keyboardHeight;
//
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
//    int width = MAX(keyboardSize.height,keyboardSize.width);
    
    //your other code here..........
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    [self moveViewUp:notification isUp:true];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
//    self.tableView.contentInset = UIEdgeInsetsZero;
//
//    self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    [self moveViewUp:notification isUp:false];

}
#pragma mark - TextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
//    [self moveViewUp:YES];
    
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
//    [self keyboardWillShow:nil];
   

//    [self moveViewUp:NO];
    
}

- (void) moveTableViewUp: (BOOL) isUp
{
    const int movementDistance = 220; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    double movement;
    if (isUp)
    {
        //            movementDistance=totalMovement;
        //            totalMovement=0;
        long lastRowNumber = [self.tableView numberOfRowsInSection:0] - 1;
        NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
        
        if (lastRowNumber > -1)
        {
            
            [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        //        [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
        
    }
    
    movement = (isUp ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
    
        UIView* bottomView = [self.view viewWithTag:4001];
        
        bottomView.frame = CGRectOffset(bottomView.frame, 0, movement);
        
        [UIView commitAnimations];
//    });
    
    
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
        if ([text isEqualToString:@"\n"])
        {
//            textView.text = [NSString stringWithFormat:@"%@\n",textView.text];
//            NSLog(@"Return pressed, do whatever you like here");
            UIView* bottomView=[self.view viewWithTag:4001];

            [textView resignFirstResponder];
            
            return NO; // or true, whetever you's like
        }
    return YES;
}

- (void) moveViewUp:(NSNotification *)notification isUp: (BOOL) isUp
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    const int movementDistance = keyboardSize.height;
    
    const float movementDuration = 0.3f;
    
    double movement;
    
    movement = (isUp ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    
    [UIView setAnimationBeginsFromCurrentState: YES];
    
    [UIView setAnimationDuration: movementDuration];
    
    UIView* bottomView = [self.view viewWithTag:4001];
    
    bottomView.frame = CGRectOffset(bottomView.frame, 0, movement);
    
    [UIView commitAnimations];
//    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
//
//    const int movementDistance = keyboardSize.height;
//
////    self.notification = notification;
//
//    const float movementDuration = 0.3f; // tweak as needed
//
//    double movement;
//
//    if (isUp)
//    {
//        //            movementDistance=totalMovement;
//        //            totalMovement=0;
//        long lastRowNumber = [self.tableView numberOfRowsInSection:0] - 1;
//
//        NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
//
//        if (lastRowNumber > -1)
//        {
//
//            [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
//        }
//        //        [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
//
//    }
//
//    movement = (isUp ? -movementDistance : movementDistance);
//
//    [UIView beginAnimations: @"anim" context: nil];
//
//    [UIView setAnimationBeginsFromCurrentState: YES];
//
//    [UIView setAnimationDuration: movementDuration];
//
//    //    dispatch_async(dispatch_get_main_queue(), ^{
//
//    UIView* bottomView = [self.view viewWithTag:4001];
//
//    bottomView.frame = CGRectOffset(bottomView.frame, 0, movement);
//
//    [UIView commitAnimations];
////    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//
//    UIEdgeInsets contentInsets;
//
//    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
//    {
//        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height), 0.0);
//    }
//    else
//    {
//        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.width), 0.0);
//    }
//
//    self.tableView.contentInset = contentInsets;
//
//    self.tableView.scrollIndicatorInsets = contentInsets;
//
//    long lastRowNumber = [self.tableView numberOfRowsInSection:0] - 1;
//
//    if (lastRowNumber > -1)
//    {
//        NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
//
//        [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
//    }
    
    //    });
    
}


#pragma mark - WebRTC Data Channel Delegate

-(void)dataChannelDidChangeState:(RTCDataChannel *)dataChannel
{
    NSLog(@"data channel state = %d", dataChannel.readyState);
    
}

-(void)dataChannel:(RTCDataChannel *)dataChannel didReceiveMessageWithBuffer:(RTCDataBuffer *)buffer
{
    if (buffer.isBinary)
    {
//        UIImage* image = [UIImage imageWithData:buffer.data];
        
           dispatch_async(dispatch_get_main_queue(), ^{
            
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
            
            imageView.image = [UIImage imageWithData:buffer.data];
            
            [self.view addSubview:imageView];

        });
        
    }
    else
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
                           
                           self.sendTextView.text = @"";
                           
                       });
        
    }
   
//    [self sendMessageUsingDataChannel:@"reply"];
}


#pragma mark - TableView Delegate And DataSource

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

#pragma mark - Storyboard Actions

- (IBAction)attachmentButtonClicked:(id)sender
{
    //    NSString* imagepath = [[NSBundle mainBundle] pathForResource:@"SampleImage" ofType:@"png"];
    //
    //    NSData* dataToSend = [[NSFileManager defaultManager] contentsAtPath:imagepath];
    //
    //    RTCDataBuffer *buffer = [[RTCDataBuffer alloc] initWithData:dataToSend isBinary:YES];
    //
    //    BOOL messageSent = [self.dataChannel sendData:buffer];
    //
    //    NSLog(@"data sent %d", messageSent);
}

- (IBAction)sendMessageButtonCLlked:(id)sender
{
    [self sendMessageUsingDataChannel:self.sendTextView.text];
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
    
//    [self.tableView reloadData];
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:self.messagesArray.count-1 inSection:0];
    
    [self.tableView insertRowsAtIndexPaths:[[NSArray alloc] initWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
//    [self moveTableViewUp:self.notification isUp:true];
//    UIView* view = [self.view viewWithTag:4001];
    
    self.sendTextView.text = @"";
    

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
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HANG_UP_CALL object:nil];

    [[APIManager sharedManager] hangUpCall:self.callerName calleUser:self.connectedPeerName];
    
    //[self dismissViewControllerAnimated:true completion:nil];
}


@end
