//
//  LoginViewController.h
//  CallSourceNewObjC
//
//  Created by mac on 09/03/18.
//  Copyright © 2018 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
- (IBAction)submitButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;

@end
