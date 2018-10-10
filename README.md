# imagePIcker
简单的图片选择封装

### 使用
```
pod 'BLImagePickerController'
#import "BLImagePickerController.h"

@interface xxxVC ()<BLImagePickerControllerDelegate>


#pragma mark - - 选择图片
- (void)handleImagePick{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    // 拍照
    UIAlertAction *camare = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _imagePicker = [[BLImagePickerController alloc] init];
        _imagePicker.delegate = self;
        [_imagePicker selectImageFromCameraSuccess:^(UIImagePickerController *imagePickerController) {
            [self presentViewController:imagePickerController animated:YES completion:nil];
        } fail:nil];
    }];
    // 相册
    UIAlertAction *photo = [UIAlertAction actionWithTitle:@"从相册中选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _imagePicker = [[BLImagePickerController alloc] init];
        _imagePicker.delegate = self;
        [_imagePicker selectImageFromAlbumSuccess:^(UIImagePickerController *imagePickerController) {
            [self presentViewController:imagePickerController animated:YES completion:nil];
        } fail:nil];
    }];
    [alert addAction:cancel];
    [alert addAction:camare];
    [alert addAction:photo];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - - BLImagePickerControllerDelegate
- (void)selectImageFinishedAndCaches:(UIImage *)image
                    cachesIdentifier:(NSString *)identifier
                     isCachesSuccess:(BOOL)isCaches{
    [self nt_upload:image];
}
```

