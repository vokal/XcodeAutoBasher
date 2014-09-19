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

- (BOOL)isAssetCatalog:(NSString *)path
{
    NSString *lastPath = [path lastPathComponent];
    NSLog(@"Extension %@", lastPath);
    if ([lastPath rangeOfString:@".xcassets"].location != NSNotFound) {
        return YES;
    } else {
        return NO;
    }
}

- (NSArray *)allSubfoldersUnderPath:(NSString *)path
{
    NSDirectoryEnumerator *catalogEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    
    NSMutableArray *subfolders = [NSMutableArray array];
    NSString *folder;
    while (folder = [catalogEnumerator nextObject]) {
        if (![folder hasSuffix:@".png"]
            && ![folder hasSuffix:@".json"]
            && ![folder hasSuffix:@".DS_STORE"]) {
            [subfolders addObject:[path stringByAppendingPathComponent:folder]];
        }
    }
    
    return subfolders;
}

- (void)watchFolderWithPath:(NSString *)watchPath
{
	if (watchPath != nil) {
        if ([self isAssetCatalog:watchPath]) {
            //DIVE DIVE DIVE
            NSArray *subfolders = [self allSubfoldersUnderPath:watchPath];
            NSLog(@"Subfolders: %@", subfolders);
            for (NSString *subfolder in subfolders) {
                [self startMonitoringDirectory:subfolder];
            }
        }
        
        //The top level dir should be watched either way.
        [self startMonitoringDirectory:watchPath];
    }
}

- (void)invalidate
{
    [self.queueueue removeAllPaths];
}

- (void)stopWatchingFolderWithPath:(NSString *)directoryPath
{
    if ([self isAssetCatalog:directoryPath]) {
        NSArray *subfolders = [self allSubfoldersUnderPath:directoryPath];
        NSLog(@"Subfolders: %@", subfolders);
        for (NSString *subfolder in subfolders) {
            [self stopMonitoringDirectory:subfolder];
        }
    }
    
    [self stopMonitoringDirectory:directoryPath];
}

- (void)startMonitoringDirectory:(NSString *)directoryPath
{
    [self.queueueue addPath:directoryPath];
}

- (void)stopMonitoringDirectory:(NSString *)directoryPath
{
    [self.queueueue removePath:directoryPath];
}

#pragma mark - VDKQueueDelegate

- (void)VDKQueue:(VDKQueue *)queue receivedNotification:(NSString *)noteName forPath:(NSString *)path
{
    NSLog(@"VOKDirectoryWatcher got path: %@", path);
    [self.delegate directoryDidChange:path];
}

@end
