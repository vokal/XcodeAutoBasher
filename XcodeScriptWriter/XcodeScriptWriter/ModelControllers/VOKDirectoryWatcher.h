//
//  VOKDirectoryWatcher.m
//  VOKXcodeScriptWriter
//
//  Created by Ellen Shapiro (Vokal) on 9/18/14.
//  Copyright (c) 2014 Vokal Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VOKDirectoryWatcher;

@protocol VOKDirectoryWatcherDelegate <NSObject>
@required
- (void)directoryDidChange:(NSString *)directory;

@end

/**
 * A simplified file watcher wrapper. 
 */
@interface VOKDirectoryWatcher : NSObject 

@property (nonatomic, weak) id <VOKDirectoryWatcherDelegate> delegate;

+ (VOKDirectoryWatcher *)sharedInstance;

- (void)watchFolderWithPath:(NSString *)watchPath;
- (void)stopWatchingFolderWithPath:(NSString *)directoryPath;
- (void)invalidate;

@end
