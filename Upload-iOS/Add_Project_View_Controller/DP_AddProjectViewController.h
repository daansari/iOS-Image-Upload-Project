//
//  DP_AddProjectViewController.h
//  Upload-iOS
//
//  Created by Danish Ahmed Ansari on 19/03/14.
//  Copyright (c) 2014 Danish Ahmed Ansari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Base64.h"

#import "DP_UploadProjectToServer.h"
#import "DP_CoreLocationManger.h"

#import <MBProgressHUD.h>

@interface DP_AddProjectViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, DP_UploadProjectToServerDelegate, UITextFieldDelegate, DP_CoreLocationMangerDelegate> {
    NSMutableData *_receivedData;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageTaken_imgView;
@property (weak, nonatomic) IBOutlet UITextField *projectName_TxtField;
@property (weak, nonatomic) IBOutlet UIButton *takePictureBtn;
@property (weak, nonatomic) IBOutlet UIButton *uploadBtn;

- (IBAction)takePictureViewBtnPressed:(id)sender;
- (IBAction)uploadData:(id)sender;

@end
