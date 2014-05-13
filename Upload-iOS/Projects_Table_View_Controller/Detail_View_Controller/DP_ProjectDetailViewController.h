//
//  DP_ProjectDetailViewController.h
//  Upload-iOS
//
//  Created by Danish Ahmed Ansari on 19/03/14.
//  Copyright (c) 2014 Danish Ahmed Ansari. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DP_ProjectDetailViewController : UIViewController

@property (nonatomic, strong) NSDictionary *project_dict;

@property (weak, nonatomic) IBOutlet UIImageView *p_image_view;
@property (weak, nonatomic) IBOutlet UILabel *project_name_lbl;
@property (weak, nonatomic) IBOutlet UILabel *image_timestamp_lbl;
@property (weak, nonatomic) IBOutlet UILabel *latitude_lbl;
@property (weak, nonatomic) IBOutlet UILabel *longitude_lbl;

@end
