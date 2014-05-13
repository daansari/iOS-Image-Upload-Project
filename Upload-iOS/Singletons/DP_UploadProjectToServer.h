//
//  DP_UploadProjectToServer.h
//  Upload-iOS
//
//  Created by Danish Ahmed Ansari on 19/03/14.
//  Copyright (c) 2014 Danish Ahmed Ansari. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DP_UploadProjectToServerDelegate;

@interface DP_UploadProjectToServer : NSObject

@property (nonatomic, weak) id<DP_UploadProjectToServerDelegate>delegate;

+ (DP_UploadProjectToServer *)sharedInstance;

@property (nonatomic, assign) NSInteger totalBytesRead, totalBytesExpectedToRead;

- (void)uploadDataForPath:(NSString *)path withParameters:(NSDictionary *)params andImageFilePath:(NSString *)filepath;

@end


@protocol DP_UploadProjectToServerDelegate <NSObject>
@optional
-(void)uploadProjectToServerClient:(DP_UploadProjectToServer *)client didUploadWithData:(id)project;
-(void)uploadProjectToServerClient:(DP_UploadProjectToServer *)client didFailWithError:(NSError *)error;
-(void)updateMBProgressWithDownloadedZip_totalBytesRead:(float)totalBytesWritten andTotalBytesExpectedToRead:(float)totalBytesExpectedToWrite;
-(void)hideProgress;
@end