        //
//  APIManager.m
//  Communicator
//
//  Created by mac on 05/04/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import "APIManager.h"
#import "AppDelegate.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CFNetwork/CFNetwork.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation APIManager
@synthesize hud;
static APIManager *singleton = nil;

// Shared method
+(APIManager *) sharedManager
{
    if (singleton == nil)
    {
        singleton = [[APIManager alloc] init];
        //[[AppPreferences sharedAppPreferences] startReachabilityNotifier];
    }

    return singleton;
}

// Init method
-(id) init
{
    self = [super init];
    
    if (self)
    {
        
    }
    
    return self;
}

#pragma mark
#pragma mark ValidateUser API
#pragma mark

//-(void) validateUser:(NSString *) usernameString andPassword:(NSString *) passwordString
//{
//    if ([[AppPreferences sharedAppPreferences] isReachable])
//    {
//        NSArray *params = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"username=%@",usernameString], [NSString stringWithFormat:@"password=%@",passwordString] ,nil];
//        
//        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:params,REQUEST_PARAMETER, nil];
//        
//        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:USER_LOGIN_API withRequestParameter:dictionary withResourcePath:USER_LOGIN_API withHttpMethd:POST];
//        [downloadmetadatajob startMetaDataDownLoad];
//    }
//    else
//    {
//        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please turn on your inernet connection to access this feature" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
//    }
//}



-(void) sendSDPUsername:(NSString *) usernameString SDP:(id)SDP sdpType:(NSString*)sdpType calleeUser:(NSString*)calleeUser allowVideo:(NSString*)allowVideo
{
//    if ([[AppPreferences sharedAppPreferences] isReachable])
//    {
        NSArray *params = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"username=%@",usernameString],[NSString stringWithFormat:@"SDP=%@", SDP],[NSString stringWithFormat:@"sdpType=%@", sdpType],[NSString stringWithFormat:@"calleeUser=%@", calleeUser],[NSString stringWithFormat:@"allowVideo=%@", allowVideo], nil];
        
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:params,REQUEST_PARAMETER, nil];
        
        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:SEND_SDP_API withRequestParameter:dictionary withResourcePath:SEND_SDP_API withHttpMethd:POST];
        [downloadmetadatajob startMetaDataDownLoad];
//    }
//    else
//    {
//        [[[UIApplication sharedApplication].keyWindow viewWithTag:789] setHidden:YES];
//
//        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please turn on your inernet connection to access this feature" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
//    }
}

-(void) hangUpCall:(NSString*)username calleUser:(NSString*)calleeUser
{
    //    if ([[AppPreferences sharedAppPreferences] isReachable])
    //    {
    NSArray *params = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"username=%@", username],[NSString stringWithFormat:@"calleeUser=%@", calleeUser], nil];
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:params,REQUEST_PARAMETER, nil];
    
    DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:HANGUP_CALL_API withRequestParameter:dictionary withResourcePath:HANGUP_CALL_API withHttpMethd:POST];
    [downloadmetadatajob startMetaDataDownLoad];
    //    }
    //    else
    //    {
    //        [[[UIApplication sharedApplication].keyWindow viewWithTag:789] setHidden:YES];
    //
    //        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please turn on your inernet connection to access this feature" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    //    }
}

-(void) getListOfRegisteredUser:(NSString*)usernameString
{
    //    if ([[AppPreferences sharedAppPreferences] isReachable])
    //    {
    NSArray *params = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"username=%@",usernameString], nil];
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:params,REQUEST_PARAMETER, nil];
    
    DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:GET_LISTOF_REGISTERED_USER withRequestParameter:dictionary withResourcePath:GET_LISTOF_REGISTERED_USER withHttpMethd:POST];
    [downloadmetadatajob startMetaDataDownLoad];
    //    }
    //    else
    //    {
    //        [[[UIApplication sharedApplication].keyWindow viewWithTag:789] setHidden:YES];
    //
    //        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please turn on your inernet connection to access this feature" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    //    }
}
-(void) updateDevieTokenUsername:(NSString *) usernameString andDeviceId:(NSString*)DeviceToken
{
//    if ([[AppPreferences sharedAppPreferences] isReachable])
//    {
        NSArray *params = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"username=%@",usernameString],[NSString stringWithFormat:@"deviceToken=%@", [AppPreferences sharedAppPreferences].deviceToken],nil];
        
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:params,REQUEST_PARAMETER, nil];
        
        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:UPDATE_DEVICE_TOKEN_API withRequestParameter:dictionary withResourcePath:UPDATE_DEVICE_TOKEN_API withHttpMethd:POST];
        [downloadmetadatajob startMetaDataDownLoad];
//    }
//    else
//    {
//        [[[UIApplication sharedApplication].keyWindow viewWithTag:789] setHidden:YES];
//        
//        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please turn on your inernet connection to access this feature" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
//    }

}


-(void) logoutUsername:(NSString *) usernameString
{
    //    if ([[AppPreferences sharedAppPreferences] isReachable])
    //    {
    NSArray *params = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"username=%@",usernameString],nil];
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:params,REQUEST_PARAMETER, nil];
    
    DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:LOGOUT_API withRequestParameter:dictionary withResourcePath:LOGOUT_API withHttpMethd:POST];
    [downloadmetadatajob startMetaDataDownLoad];
    //    }
    //    else
    //    {
    //        [[[UIApplication sharedApplication].keyWindow viewWithTag:789] setHidden:YES];
    //
    //        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please turn on your inernet connection to access this feature" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    //    }
    
}

-(void) sendCandidateUsername:(NSString *) usernameString candidate:(id)candidate allowVideo:(NSString*)allowVideo
{
    NSArray *params = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"username=%@",usernameString],[NSString stringWithFormat:@"Candidate=%@", candidate],[NSString stringWithFormat:@"allowVideo=%@", allowVideo],nil];
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:params,REQUEST_PARAMETER, nil];
    
    DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:SEND_CANDIDATES_API withRequestParameter:dictionary withResourcePath:SEND_CANDIDATES_API withHttpMethd:POST];
    [downloadmetadatajob startMetaDataDownLoad];
}

-(void) getICECredentials
{
//    NSArray *params = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"username=%@",usernameString],[NSString stringWithFormat:@"Candidate=%@", candidate],nil];
    
 //   NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:params,REQUEST_PARAMETER, nil];
    
    NSDictionary *dictionary = [NSDictionary new];
    
    DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:XIR_GET_CRED_API withRequestParameter:dictionary withResourcePath:XIR_GET_CRED_API withHttpMethd:PUT];
    
    [downloadmetadatajob getICEFromXIR];
}


@end
