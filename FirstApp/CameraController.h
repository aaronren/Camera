//
//  CameraController.h
//  FirstApp
//
//  Created by Aaron Ren on 14-10-4.
//  Copyright (c) 2014年 Ren Aaron. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    void(^captured)();
}

@property (nonatomic,strong) UIImagePickerController* imagePickerController;
@property (nonatomic,weak)   IBOutlet UIImageView* watermarkView;
@property (nonatomic,weak)   IBOutlet UIActivityIndicatorView* indicatorView;

- (void)setPhotoCapturedBlock:(void(^)())block;

@end
