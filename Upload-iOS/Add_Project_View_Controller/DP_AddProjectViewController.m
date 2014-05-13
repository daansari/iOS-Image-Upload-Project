//
//  DP_AddProjectViewController.m
//  Upload-iOS
//
//  Created by Danish Ahmed Ansari on 19/03/14.
//  Copyright (c) 2014 Danish Ahmed Ansari. All rights reserved.
//

#import "DP_AddProjectViewController.h"

#import <TSMessage.h>

@interface DP_AddProjectViewController ()

@property (nonatomic, strong) DP_UploadProjectToServer *client;
@property (nonatomic, strong) NSString *image_data_str;

@property (nonatomic, strong) DP_CoreLocationManger *locationManager;
@property (nonatomic, assign) CLLocationDistance locationDistanceMeters;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) NSString *imageTakenTimeStamp;

// MBProgressHUD
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation DP_AddProjectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Add Project";
    self.navigationController.navigationBar.translucent = FALSE;
    
    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelBarButtonPressed:)];
    self.navigationItem.leftBarButtonItem = cancelBarButton;
    
    _hud = [[MBProgressHUD alloc] initWithView:self.view];
    
    [_hud setLabelFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f]];
    
    [_hud setMode:MBProgressHUDModeIndeterminate];
    
    [self.view addSubview:_hud];
    
    _locationManager = [DP_CoreLocationManger sharedInstance];
    
    if (_locationManager != nil) {
        _locationManager.delegate = self;
        [_hud setLabelText:@"Getting User Location"];
        [_hud show:YES];
        [self setupUIElements];
    }

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshUserLocationOnAppWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopUserLocationOnAppDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    
    if (_locationManager != nil) {
    
        [_locationManager.dp_locationManager stopUpdatingLocation];
    
        _locationManager.delegate = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if ([self.view window] == nil) {
        self.imageTaken_imgView = nil;
        self.projectName_TxtField = nil;
        self.takePictureBtn = nil;
        self.uploadBtn = nil;
    }
}

- (void)dealloc
{
    self.locationManager.delegate = nil;
    self.client.delegate = nil;
}

- (void)refreshUserLocationOnAppWillEnterForeground:(NSNotification *)notification {
    if (_locationManager != nil) {
        [_hud setLabelText:@"Getting User Location"];
        [_hud show:YES];
        [self setupLocationElements];
    }
}

- (void)stopUserLocationOnAppDidEnterBackground:(NSNotification *)notification {
    NSLog(@"Location Manager Did Enter Background Test Passed");
    
    if (_locationManager != nil) {
        
        [_locationManager.dp_locationManager stopUpdatingLocation];
        [_hud setLabelText:@""];
        [_hud hide:TRUE];
    
    }
}

- (void)setupUIElements {
    [self setupLocationElements];
}

- (void)setupLocationElements {
    if ([self checkForLocationAuthorization]) {
        _locationManager.delegate = self;
        [_locationManager.dp_locationManager startUpdatingLocation];
    }
    else {
        [_hud setLabelText:@""];
        [_hud hide:YES];
        [self showErrorMessage:@"Location Error" andSubtitle:@"Locations Services Disabled for Upload-iOS.\nPlease Allow Location Services. \nSettings > Privacy > Location Services > projectDeen"];
    }
}

- (IBAction)cancelBarButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)uploadData:(id)sender {
    
    if ([self.image_data_str length] > 0 && [self.projectName_TxtField.text length] > 0) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:self.projectName_TxtField.text, @"name", [NSString stringWithFormat:@"%f", self.currentLocation.coordinate.latitude], @"p_latitude", [NSString stringWithFormat:@"%f", self.currentLocation.coordinate.longitude], @"p_longitude", self.imageTakenTimeStamp, @"timestamp_str", self.image_data_str, @"image_data", nil], @"project", nil];
        
        [_hud show:YES];
        self.client = [DP_UploadProjectToServer sharedInstance];
        self.client.delegate = self;
        [self.client uploadDataForPath:@"projects" withParameters:dict andImageFilePath:nil];
    }
    else {
        [self showErrorMessage:@"Error" andSubtitle:@"Picture / Project Name is missing."];
    }
    

}

- (IBAction)takePictureViewBtnPressed:(id)sender {
    if ([self checkForLocationAuthorization]) {
        if (_locationDistanceMeters >= 0 && _locationDistanceMeters <= DP_DISTANCE_RADIUS_FILTER) {
            [self startCameraControllerFromViewController: self
                                            usingDelegate: self];
        }
        else {
            [self showErrorMessage:@"Error" andSubtitle:@"Cannot take pictures since you are not within a specified radius."];
        }
    }
    else {
        [self showErrorMessage:@"Location Error" andSubtitle:@"Locations Services Disabled for Upload-iOS.\nPlease Allow Location Services. \nSettings > Privacy > Location Services > projectDeen"];
    }
}

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    cameraUI.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = YES;
    
    cameraUI.delegate = delegate;
    
    cameraUI.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [controller presentViewController:cameraUI animated:UIModalPresentationFullScreen completion:nil];
    
    return YES;
}

#pragma -
#pragma Image Picker Delegate Methds

- (void)imagePickerControllerDidCancel:(UIImagePickerController *) picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    NSDictionary *metaData = [info objectForKey:UIImagePickerControllerMediaMetadata];
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        // Set the image preview to the new image.
        self.imageTaken_imgView.image = [info objectForKey:UIImagePickerControllerEditedImage];
        
        // Convert our image to Base64 encoding.
        NSData *imageData = UIImagePNGRepresentation([info objectForKey:UIImagePickerControllerEditedImage]);
        [Base64 initialize];
        NSString *imageDataEncodedString = [Base64 encode:imageData];
        
        // Add the encoded image.
        self.image_data_str = imageDataEncodedString;
        
        NSString *image_date = metaData[@"{Exif}"][@"DateTimeOriginal"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
        NSDate *date = [dateFormatter dateFromString:image_date];
        
        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        [dateFormatter setTimeZone:gmt];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString * formatted_date = [dateFormatter stringFromDate:date];
        
        self.imageTakenTimeStamp = formatted_date;
    }
    
    // And dismiss the image picker.
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

# pragma mark - UITextField Delegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)updateMBProgressWithDownloadedZip_totalBytesRead:(float)totalBytesWritten andTotalBytesExpectedToRead:(float)totalBytesExpectedToWrite {
    float totalMegabytesToBeRead = (float)totalBytesExpectedToWrite / 1048576;
    float totalMegabytesRead = (float)totalBytesWritten / 1048576;
    
    if (_hud.mode != MBProgressHUDModeIndeterminate) {
        _hud.mode = MBProgressHUDModeIndeterminate;
    }
    
    _hud.labelText = @"Uploading...";
    
    _hud.detailsLabelText = [NSString stringWithFormat:@"%.2f Mb of %.2f Mb", totalMegabytesRead, totalMegabytesToBeRead];
}

- (void)hideProgress {
    _hud.labelText = @"Finished Uploading";
    _hud.detailsLabelText = @"";
    
    [_hud hide:YES afterDelay:1.0f];
    self.image_data_str = @"";
    self.imageTaken_imgView.image = nil;
    self.projectName_TxtField.text = @"";
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark - DP_CoreLocationManager Delegate Method
- (void)didChangeAuthorizationStatus {
    if ([self checkForLocationAuthorization]) {
        [self setupUIElements];
    }
    else {
        [_hud setLabelText:@""];
        [_hud hide:YES];
    }
}

- (void)locationUpdate:(CLLocation *)location {
    CLLocation *userLocation = location;

    _currentLocation = userLocation;
    
    NSNumber *dp_latitude = [NSNumber numberWithDouble:DP_LATITUDE];
    NSNumber *dp_longitude = [NSNumber numberWithDouble:DP_LONGITUDE];
    
    CLLocationCoordinate2D savedCityCoord = CLLocationCoordinate2DMake([dp_latitude doubleValue], [dp_longitude doubleValue]);
    CLLocation *savedCityLocation = [[CLLocation alloc] initWithLatitude:savedCityCoord.latitude longitude:savedCityCoord.longitude];
    
    _locationDistanceMeters = [userLocation distanceFromLocation:savedCityLocation];
    
    if (_hud.alpha > 0) {
        [_hud setLabelText:@""];
        [_hud hide:YES];
    }
}

- (void)locationError:(NSError *)error {
    NSLog(@"Error - %@, %@", error, [error userInfo]);
}

- (void)showErrorMessage:(NSString *)title andSubtitle:(NSString *)subtitle {
    [TSMessage showNotificationInViewController:self
                                          title:title
                                       subtitle:subtitle
                                          image:nil
                                           type:TSMessageNotificationTypeError
                                       duration:TSMessageNotificationDurationAutomatic
                                       callback:nil
                                    buttonTitle:nil
                                 buttonCallback:nil
                                     atPosition:TSMessageNotificationPositionTop canBeDismissedByUser:YES];

}

- (BOOL)checkForLocationAuthorization {
    return [CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined);
}

@end
