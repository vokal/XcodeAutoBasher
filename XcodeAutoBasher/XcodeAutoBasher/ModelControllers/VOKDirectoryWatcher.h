//
//  VOKDirectoryWatcher.m
//  VOKXcodeAutoBasher
//
//  Created by Ellen Shapiro (Vokal) on 9/18/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VOKDirectoryWatcher, VOKScriptForFolder;

@protocol VOKDirectoryWatcherDelegate <NSObject>
@required

/**
 *  Notifies the delegate that a given directory had changes.
 *  @param directory The full path to the directory which changed.
 */
- (void)directoryDidChange:(NSString *)directory;

@end

/**
 * A simplified file watcher wrapper. 
 */
@interface VOKDirectoryWatcher : NSObject 

///The delegate to notify of changes.
@property (nonatomic, weak) id <VOKDirectoryWatcherDelegate> delegate;

/**
 *  @return Singleton instance.
 */
+ (VOKDirectoryWatcher *)sharedInstance;

/**
 *  Start watching a given folder.
 *  @param folder The folder to watch.
 */
- (void)watchFolder:(VOKScriptForFolder *)folder;

/**
 *  Stop watching a given folder.
 *  @param folder The folder to stop watching.
 */
- (void)stopWatchingFolder:(VOKScriptForFolder *)folder;

/**
 *  A list of the subfolders under a given path
 *
 *  @param path The path to grab the list of subfolders.
 *  @return An array of strings representing the full paths of all subfolders.
 */
- (NSArray *)allSubfoldersUnderPath:(NSString *)path;

/**
 *  Kills directory watcher with fire.
 */
- (void)invalidate;

@end
