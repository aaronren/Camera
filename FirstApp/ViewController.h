//
//  ViewController.h
//  FirstApp
//
//  Created by Aaron Ren on 14-10-3.
//  Copyright (c) 2014年 Ren Aaron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,weak) IBOutlet UITableView* tableView;

@property (nonatomic,strong) NSMutableArray* photoArray;

@end

