//
//  ReigisteredUsersViewController.m
//  CallSourceNewObjC
//
//  Created by mac on 10/03/18.
//  Copyright © 2018 Xanadutec. All rights reserved.
//

#import "ReigisteredUsersViewController.h"
#import "ViewController.h"

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

    // Do any additional setup after loading the view.
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
    
    userNameLabel.text = [NSString stringWithFormat:@"%@",[self.registeredUserArray objectAtIndex:indexPath.row]];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UILabel* userNameLabel = [cell viewWithTag:101];
    
    ViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    
    vc.calleName = userNameLabel.text;
    
    [self presentViewController:vc animated:YES completion:nil];
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

@end
