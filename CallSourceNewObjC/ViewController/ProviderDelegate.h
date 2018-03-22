//
//  ProviderDelegate.h
//  CallSourceNewObjC
//
//  Created by mac on 13/03/18.
//  Copyright © 2018 Xanadutec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CallKit/CallKit.h>

@interface ProviderDelegate : NSObject<CXProviderDelegate>
{
    //CallManager* manager;
    CXProvider* provider;
    CXCallDirectoryManager* callManager;
}

@property (strong, nonatomic) CXProvider * provider;
@property (weak, nonatomic) NSTimer * providerTimer;
// GETTER DECLARATION
+(CXProviderConfiguration *)providerConfiguration;
-(void)displayIncomingCall:(NSUUID *)uuid handle:(NSString *)handle hasVideo:(BOOL)flag withCompletion:(void(^)(NSError *error))completion;
//{

//    fileprivate let callManager: CallManager
//    fileprivate let provider: CXProvider
//}


@end
