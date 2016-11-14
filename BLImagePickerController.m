//
//  BLImagePickerController.m
//  EaseUIImagePickerController
//
//  Created by boundlessOcean on 16/6/13.
//
//


#import "BLImagePickerController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface BLImagePickerController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong) UIImagePickerController * imagePickerController;

@property (nonatomic,strong) UIImage * image;

@end

//是否采用裁剪后的图片
static BOOL bl_isEditImage = YES;

@implementation BLImagePickerController

- (void)setIsEditImage:(BOOL)isEditImage{
    bl_isEditImage = isEditImage;
}

#pragma mark - 初始化方法
- (instancetype)initWithIsCaches:(BOOL)isCaches andIdentifier:(NSString *)identifier{
    self = [super init];
    if (self) {
        self.isCaches = isCaches;
        self.identifier = identifier;
    }
    return self;
}

#pragma mark - 来自相机
- (void)selectImageFromCameraSuccess:(CameraSuccess)success fail:(CameraFail)failure{
    if (failure) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied) {
            failure(self.imagePickerController);
            return;
        }
    }
    if (success) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
            self.imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            success(self.imagePickerController);
        }
    }
}

#pragma mark - 来自相簿
- (void)selectImageFromAlbumSuccess:(AlbumSuccess)success fail:(AlbumFail)failure{
    if (failure) {
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        if (status == ALAuthorizationStatusRestricted || status == ALAuthorizationStatusDenied) {
            failure(self.imagePickerController);
            return;
        }
    }
    if (success) {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        success(self.imagePickerController);
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString * mediaType = info[UIImagePickerControllerMediaType];
    if (mediaType == (NSString *)kUTTypeImage) {
        if (bl_isEditImage) {
            self.image = info[UIImagePickerControllerEditedImage];
        }else {
            self.image = info[UIImagePickerControllerOriginalImage];
        }
        NSString * url = info[UIImagePickerControllerMediaURL];
        NSLog(@"uuu:%@",url);
        if ([self.delegate respondsToSelector:@selector(selectImageFinishedAndCaches:cachesIdentifier:isCachesSuccess:)]) {
            BOOL cachesStatus = [self saveImageToCaches:self.image
                                             identifier:self.identifier];
            [self.delegate selectImageFinishedAndCaches:self.image
                                       cachesIdentifier:self.identifier
                                        isCachesSuccess:cachesStatus];
            [_imagePickerController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark - 读取缓存的图片
- (UIImage *)readImageFromCachesIdentifier:(NSString *)identifier {
    NSString * path = [NSString stringWithFormat:@"%@/%@",cachesPath(),identifier];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData * imgeData = [[NSFileManager defaultManager] contentsAtPath:path];
        if (imgeData) {
            UIImage * image = [[UIImage alloc]initWithData:imgeData];
            return image;
        }
    }
    return nil;
}

#pragma mark - 删除指定缓存的图片
- (BOOL)removeCachePictureForIdentifier:(NSString *)identifier {
    NSString * path = [NSString stringWithFormat:@"%@/%@",cachesPath(),identifier];
    if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
        NSError * error ;
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        if (error) {
            NSLog(@"remove picture for id:%@ failure",identifier);
            return false;
        }
        return true;
    }
    return false;
}

#pragma mark - 删除全部图片
- (BOOL)removeCachePictures{
    if ([[NSFileManager defaultManager]fileExistsAtPath:cachesPath()]) {
        NSError * error;
        [[NSFileManager defaultManager] removeItemAtPath:cachesPath() error:&error];
        if (error) {
            NSLog(@"remove pictures fail , error : %@ , path = %@",error,cachesPath());
            return false;
        }
        return true;
    }
    return false;
}

#pragma mark - 缓存图片
- (BOOL)saveImageToCaches:(UIImage *)image identifier:(NSString *)identifier {
    NSData * imageData = UIImageJPEGRepresentation(image, 0.5);
    if (imageData) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:cachesPath()]) {
            NSError * error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:cachesPath()
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:&error];
            if (error) {
                NSLog(@"create cache dir error: %@   path: %@",error,cachesPath());
                return false;
            }
            NSLog(@"creat cache dir success :%@",cachesPath());
        }
        if (self.identifier) {
            NSString * path = [NSString stringWithFormat:@"%@/%@",cachesPath(),self.identifier];
            BOOL isSuccess = [[NSFileManager defaultManager] createFileAtPath:path
                                                                     contents:imageData
                                                                   attributes:nil];
            if (isSuccess) {
                return YES;
            }
        }
    }
    return false;
}

- (UIImagePickerController *)imagePickerController{
    if (_imagePickerController == nil) {
        _imagePickerController = [[UIImagePickerController alloc]init];
        _imagePickerController.delegate = self;
        _imagePickerController.allowsEditing = bl_isEditImage;
    }
    return _imagePickerController;
}

static inline NSString * cachesPath(){
    return [NSString stringWithFormat:@"%@/blImageCaches",NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true)[0]];
}

- (void)dealloc{
    NSLog(@"dealloc : %@",self);
}
@end
