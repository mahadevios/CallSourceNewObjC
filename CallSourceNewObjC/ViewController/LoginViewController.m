//
//  LoginViewController.m
//  CallSourceNewObjC
//
//  Created by mac on 09/03/18.
//  Copyright © 2018 Xanadutec. All rights reserved.
//

#import "LoginViewController.h"
#import "AppPreferences.h"
#import "ViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
   
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

- (IBAction)submitButtonClicked:(id)sender
{
    if ([_usernameTextField.text  isEqualToString: @""])
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Invalid Username!" withMessage:@"Please enter a valid username" withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setValue:_usernameTextField.text forKey:USERDEFAULT_USER];
        
        ViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];

        [[[UIApplication sharedApplication] keyWindow] setRootViewController:viewController];
        
//         [[APIManager sharedManager] updateDevieTokenUsername:@"iPhone" andDeviceId:deviceToken];
    }
}
@end
