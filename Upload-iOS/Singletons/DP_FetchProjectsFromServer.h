//
//  DP_FetchProjectsFromServer.h
//  Upload-iOS
//
//  Created by Danish Ahmed Ansari on 19/03/14.
//  Copyright (c) 2014 Danish Ahmed Ansari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFHTTPSessionManager.h>

@protocol DP_ProjectsHTTPClientDelegate;

@interface DP_FetchProjectsFromServer : AFHTTPSessionManager

@property (nonatomic, weak) id<DP_ProjectsHTTPClientDelegate>delegate;

+ (DP_FetchProjectsFromServer *)sharedInstance;

- (void)getDataForPath:(NSString *)path withParameters:(NSDictionary *)params;

@end

@protocol DP_ProjectsHTTPClientDelegate <NSObject>
@optional
-(void)projectsHTTPClient:(DP_FetchProjectsFromServer *)client didUpdateWithData:(id)projects;
-(void)projectsHTTPClient:(DP_FetchProjectsFromServer *)client didFailWithError:(NSError *)error;
@end