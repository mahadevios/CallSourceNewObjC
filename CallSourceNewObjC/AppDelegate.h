//
//  AppDelegate.h
//  CallSourceNewObjC
//
//  Created by mac on 05/10/17.
//  Copyright © 2017 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PushKit/PushKit.h>
#import "RTCPeerConnectionFactory.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,PKPushRegistryDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PKPushRegistry * voipRegistry;


@end

