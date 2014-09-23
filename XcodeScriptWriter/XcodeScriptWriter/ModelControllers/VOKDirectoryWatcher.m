//
//  VOKDirectoryWatcher.m
//  VOKXcodeScriptWriter
//
//  Created by Ellen Shapiro (Vokal) on 9/18/14.
//  Copyright (c) 2014 Vokal Interactive. All rights reserved.
//


#import "VOKDirectoryWatcher.h"

#import "VDKQueue.h"
#import "VOKScriptForFolder.h"

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

- (NSArray *)allSubfoldersUnderPath:(NSString *)path
{
    NSDirectoryEnumerator *catalogEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    
    NSMutableArray *subfolders = [NSMutableArray array];
    NSString *folder;
    while (folder = [catalogEnumerator nextObject]) {
        if ([[folder pathExtension] length] == 0
            && ![folder hasSuffix:@".DS_Store"])  {
            [subfolders addObject:[path stringByAppendingPathComponent:folder]];
        }
    }
    
    return subfolders;
}

- (void)watchFolder:(VOKScriptForFolder *)folder
{
    [self startMonitoringDirectory:folder.pathToFolder];
}

- (void)invalidate
{
    [self.queueueue removeAllPaths];
}

- (void)stopWatchingFolder:(VOKScriptForFolder *)folder
{
    [self stopMonitoringDirectory:folder.pathToFolder];
}

- (void)startMonitoringDirectory:(NSString *)directoryPath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
        [self.queueueue addPath:directoryPath];
    }
}

- (void)stopMonitoringDirectory:(NSString *)directoryPath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
        [self.queueueue removePath:directoryPath];
    }
}

#pragma mark - VDKQueueDelegate

- (void)VDKQueue:(VDKQueue *)queue receivedNotification:(NSString *)noteName forPath:(NSString *)path
{
    NSLog(@"VOKDirectoryWatcher got path: %@", path);
    [self.delegate directoryDidChange:path];
}

@end
