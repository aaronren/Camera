//
//  ViewController.m
//  FirstApp
//
//  Created by Aaron Ren on 14-10-3.
//  Copyright (c) 2014年 Ren Aaron. All rights reserved.
//

#import "ViewController.h"
#import "CameraController.h"
#import "TableViewCell.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.photoArray = [[NSMutableArray alloc] init];
    
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setTableHeaderView:headerView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadFromCameraRoll:^{
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"gotoCamera"])
    {
        CameraController* cameraController = segue.destinationViewController;
        
        [cameraController setPhotoCapturedBlock:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

- (void)loadFromCameraRoll:(void(^)())finished
{
    [self.photoArray removeAllObjects];
    
    id photoArr = [NSArray arrayWithContentsOfFile:[self mapFilePath]];
    if (photoArr && [photoArr isKindOfClass:[NSArray class]]) {
        self.photoArray = [NSMutableArray arrayWithArray:photoArr];
    } else {
        self.photoArray = [NSMutableArray array];
    }
    
    if (finished) {
        finished();
    }
}

#pragma mark - TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.photoArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 倒序
    NSInteger index = self.photoArray.count - 1 - indexPath.row;
    
    NSDictionary* photoInfo = [self.photoArray objectAtIndex:index];
    NSNumber *width = [photoInfo valueForKey:@"width"];
    NSNumber *height = [photoInfo valueForKey:@"height"];
    return height.integerValue * (self.view.bounds.size.width-20) / width.integerValue + 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"photoCell";
    TableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    
    NSInteger index = _photoArray.count - 1 - indexPath.row;
    NSDictionary* photoInfo = [_photoArray objectAtIndex:index];
    
    NSString *filePath = [photoInfo valueForKey:@"filePath"];
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    
    [cell.imageView setImage:image];
    
    return cell;
}

#pragma mark - 照片管理

- (NSString *)mapFilePath
{
    return [[self cacheDirectory] stringByAppendingPathComponent:@"imagelist.plist"];
}

- (NSString *)cacheDirectory
{
    NSString *cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *directory = [cachesDirectory stringByAppendingPathComponent:@"Images"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:directory]) {
        if ([[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil]) {
            return directory;
        } else {
            return nil;
        }
    }
    return directory;
}

@end
