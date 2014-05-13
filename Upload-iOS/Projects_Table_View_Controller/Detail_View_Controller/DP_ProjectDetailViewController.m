//
//  DP_ProjectDetailViewController.m
//  Upload-iOS
//
//  Created by Danish Ahmed Ansari on 19/03/14.
//  Copyright (c) 2014 Danish Ahmed Ansari. All rights reserved.
//

#import "DP_ProjectDetailViewController.h"
#import <UIImageView+AFNetworking.h>

@interface DP_ProjectDetailViewController ()

@end

@implementation DP_ProjectDetailViewController

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
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.translucent = FALSE;
    
    [self setFetchedImageToImageView];
    
    self.title = self.project_dict[@"name"];
    self.project_name_lbl.text = self.project_dict[@"name"];
    self.latitude_lbl.text = [NSString stringWithFormat:@"%@", self.project_dict[@"p_latitude"]];
    self.longitude_lbl.text = [NSString stringWithFormat:@"%@", self.project_dict[@"p_longitude"]];
    [self formatedTimeStamp];
    

}

- (void)setFetchedImageToImageView {
    __weak UIImageView *projectImageView = self.p_image_view;
    
    NSURL *url = [NSURL URLWithString:_project_dict[@"attachment_medium_url"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [projectImageView setImageWithURLRequest:request
                            placeholderImage:nil
                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                         projectImageView.image = image;
                                         [projectImageView setNeedsLayout];
                                     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                         NSLog(@"FAILED TO DOWNLOAD IMAGE IN DETAIL VIEW - %@", [error localizedDescription]);
                                     }];
}

- (void)formatedTimeStamp {
    NSString *date_str = [NSString stringWithFormat:@"%@", self.project_dict[@"p_formatted_timestamp"]];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    NSDate *date = [dateFormatter dateFromString:date_str];
    
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"dd-MM-yyyy hh:mm a"];
    NSString * formatted_date = [dateFormatter stringFromDate:date];
    
    self.image_timestamp_lbl.text = formatted_date;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if ([self.view window] == nil) {
        self.p_image_view = nil;
        self.project_name_lbl = nil;
        self.image_timestamp_lbl = nil;
        self.latitude_lbl = nil;
        self.longitude_lbl = nil;
    }
}

@end
