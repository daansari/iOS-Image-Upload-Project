//
//  DP_FetchProjectsFromServer.m
//  Upload-iOS
//
//  Created by Danish Ahmed Ansari on 19/03/14.
//  Copyright (c) 2014 Danish Ahmed Ansari. All rights reserved.
//

#import "DP_FetchProjectsFromServer.h"



@implementation DP_FetchProjectsFromServer

+ (DP_FetchProjectsFromServer *)sharedInstance {
    static DP_FetchProjectsFromServer *_sharedProjectsHTTPClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedProjectsHTTPClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:ImageUploadProjectAPIURLString]];
    });
    
    return _sharedProjectsHTTPClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    return self;
}

- (void)getDataForPath:(NSString *)path withParameters:(NSDictionary *)params {
    
    [self GET:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([self.delegate respondsToSelector:@selector(projectsHTTPClient:didUpdateWithData:)]) {
            [self.delegate projectsHTTPClient:self didUpdateWithData:responseObject];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(projectsHTTPClient:didFailWithError:)]) {
            [self.delegate projectsHTTPClient:self didFailWithError:error];
        }
    }];
}

@end
