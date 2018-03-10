//
//  ReigisteredUsersViewController.h
//  CallSourceNewObjC
//
//  Created by mac on 10/03/18.
//  Copyright © 2018 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReigisteredUsersViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) NSMutableArray* registeredUserArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
