//
//  APIManager.h
//  Communicator
//
//  Created by mac on 05/04/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadMetaDataJob.h"
#import "MBProgressHUD.h"
#import "AppPreferences.h"

@interface APIManager : NSObject
{
    NSDictionary* result;

}

+(APIManager *) sharedManager;
@property(nonatomic,strong)MBProgressHUD * hud;

//-(void) validateUser:(NSString *) usernameString andPassword:(NSString *) passwordString;

-(void) updateDevieTokenUsername:(NSString *) usernameString andDeviceId:(NSString*)DeviceToken;
-(void) sendSDPUsername:(NSString *) usernameString SDP:(id)SDP sdpType:(NSString*)sdpType calleeUser:(NSString*)calleeUser;
-(void) sendCandidateUsername:(NSString *) usernameString candidate:(id)candidate;
-(void) getICECredentials;
-(void) getListOfRegisteredUser:(NSString*)usernameString;
-(void) logoutUsername:(NSString *) usernameString;
@end
