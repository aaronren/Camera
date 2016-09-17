//
//  CameraController.m
//  FirstApp
//
//  Created by Aaron Ren on 14-10-4.
//  Copyright (c) 2014年 Ren Aaron. All rights reserved.
//

#import "CameraController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation CameraController

@synthesize imagePickerController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.indicatorView.alpha = 0;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!imagePickerController) {
        [self performSelector:@selector(showCamera) withObject:nil afterDelay:0.3];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)showCamera
{
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    imagePickerController.showsCameraControls = NO;
    [self presentViewController:imagePickerController animated:NO completion:^{
        imagePickerController.cameraOverlayView = self.view;
    }];
}

- (void)setPhotoCapturedBlock:(void(^)())block
{
    captured = block;
}

- (IBAction)takePhoto:(id)sender
{
    if (self.indicatorView.alpha==0) {
        self.indicatorView.alpha = 1;
        [imagePickerController takePicture];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* capturedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    NSDictionary* newMeta = [info valueForKey:UIImagePickerControllerMediaMetadata];
    
    /*
    // 存到系统相册
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:[capturedImage CGImage]
                                 metadata:newMeta
                          completionBlock:^(NSURL *assetURL, NSError *error) {
        if (!error && assetURL) {
            [library assetForURL:assetURL
                     resultBlock:^(ALAsset *asset) {
                         UIImage* screenImage = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
                         UIImage* finalImage = [self createCard:screenImage];
                         [library writeImageToSavedPhotosAlbum:[finalImage CGImage]
                                                      metadata:nil
                                               completionBlock:^(NSURL *assetURL, NSError *error) {
                                                   self.indicatorView.alpha = 0;
                                                   captured();
                                               }];
                     }
                    failureBlock:nil];
        }
    }];
     */
}

- (void)saveImage:(UIImage *)image
{
    NSMutableArray *photoArray = [NSMutableArray array];
        
    id photoArr = [NSArray arrayWithContentsOfFile:[self mapFilePath]];
    if (photoArr && [photoArr isKindOfClass:[NSArray class]]) {
        photoArray = [NSMutableArray arrayWithArray:photoArr];
    }
    
    //
    NSData *data = UIImageJPEGRepresentation(image, 0.8);
    
    // 以时间命名的文件名
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMdd_HHmmss";
    NSString *fileName = [[formatter stringFromDate:[NSDate date]] stringByAppendingPathExtension:@".jpg"];
    
    // 文件路径
    NSString *filePath = [[self cacheDirectory] stringByAppendingPathComponent:fileName];
    
    [data writeToFile:filePath atomically:YES];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    filePath, @"filePath",
                                    @(image.size.width), @"width",
                                    @(image.size.height), @"height",
                                    nil];
        
        if (![photoArray containsObject:filePath]) {
            [photoArray addObject:dic];
            [photoArray writeToFile:[self mapFilePath] atomically:YES];
        }
    }
}

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

#pragma mark - create watermark photo and save image

- (UIImage*)createCard:(UIImage*)image
{
    // 计算卡片大小
    CGFloat cardWidth = image.size.width;
    CGFloat cardHeight = image.size.height;
    
    // 生成新图片，并绘制内容
    CGSize newSize = CGSizeMake(cardWidth, cardHeight);
    UIGraphicsBeginImageContext(newSize);
    
    // 背景白色
    [[UIColor whiteColor] set];
    CGContextFillRect(UIGraphicsGetCurrentContext(),CGRectMake(0,0,cardWidth,cardHeight));
    
    // 绘制上照片
    [image drawInRect:CGRectMake(0,0,cardWidth,cardHeight)];
    
    [self.watermarkView.image drawInRect:CGRectMake(self.watermarkView.frame.origin.x*2,
                                                    self.watermarkView.frame.origin.y*2,
                                                    self.watermarkView.frame.size.width*2,
                                                    self.watermarkView.frame.size.height*2)];
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
