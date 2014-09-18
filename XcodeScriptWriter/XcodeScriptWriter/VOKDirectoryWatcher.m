//
//  VOKDirectoryWatcher.m
//  VOKXcodeScriptWriter
//
//  Created by Ellen Shapiro (Vokal) on 9/18/14.
//  Copyright (c) 2014 Vokal Interactive. All rights reserved.
//


#import "VOKDirectoryWatcher.h"

#import "VDKQueue.h"

@interface VOKDirectoryWatcher() <VDKQueueDelegate>
@property (nonatomic) VDKQueue *queueueue;

@end

@implementation VOKDirectoryWatcher

- (instancetype)init
{
    if (self = [super init]) {
        _queueueue = [[VDKQueue alloc] init];
        _queueueue.delegate = self;
    }
	
	return self;
}

static VOKDirectoryWatcher *_sharedInstance;
+ (VOKDirectoryWatcher *)sharedInstance
{    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[VOKDirectoryWatcher alloc] init];
    });
    
    return _sharedInstance;
}

- (void)dealloc
{
	[self invalidate];
}

- (void)watchFolderWithPath:(NSString *)watchPath
{
	if (watchPath != nil) {
		[self startMonitoringDirectory:watchPath];
    }
}

- (void)invalidate
{
    [self.queueueue removeAllPaths];
}

- (void)startMonitoringDirectory:(NSString *)directoryPath
{
    [self.queueueue addPath:directoryPath];
}

#pragma mark - VDKQueueDelegate

- (void)VDKQueue:(VDKQueue *)queue receivedNotification:(NSString *)noteName forPath:(NSString *)path
{
    NSLog(@"VOKDirectoryWatcherGOtPath %@", path);
    [self.delegate directoryDidChange:path];
}

@end
