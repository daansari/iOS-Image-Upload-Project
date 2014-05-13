//
//  DP_UploadProjectToServer.m
//  Upload-iOS
//
//  Created by Danish Ahmed Ansari on 19/03/14.
//  Copyright (c) 2014 Danish Ahmed Ansari. All rights reserved.
//

#import "DP_UploadProjectToServer.h"

#import <AFHTTPRequestOperationManager.h>

@implementation DP_UploadProjectToServer

+ (DP_UploadProjectToServer *)sharedInstance {
    static DP_UploadProjectToServer *_sharedUploadProjectToServerClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedUploadProjectToServerClient = [[self alloc] init];
    });
    
    return _sharedUploadProjectToServerClient;
}

- (id)init {
    self = [super init];
    
    if (self) {
        
    }
    return self;
}

- (void)uploadDataForPath:(NSString *)path withParameters:(NSDictionary *)params andImageFilePath:(NSString *)filepath{
    
    // Create the URL Request and set it's method and content type.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@projects", ImageUploadProjectAPIURLString]]];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    
    // Convert our dictionary to JSON and NSData
    NSData *newProjectJSONData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    
    // Assign the request body
    [request setHTTPBody:newProjectJSONData];

    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
        self.totalBytesRead = totalBytesWritten;
        self.totalBytesExpectedToRead = totalBytesExpectedToWrite;
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(updateMBProgressWithDownloadedZip_totalBytesRead:andTotalBytesExpectedToRead:)]) {
                
                if (totalBytesWritten == totalBytesExpectedToWrite) {
                    [self.delegate hideProgress];
                }
                else {
                    [self.delegate updateMBProgressWithDownloadedZip_totalBytesRead:(float)totalBytesWritten andTotalBytesExpectedToRead:totalBytesExpectedToWrite];
                }
            }
            
        });
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"Success: %@", dict);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_DATA" object:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [operation start];
}

@end
