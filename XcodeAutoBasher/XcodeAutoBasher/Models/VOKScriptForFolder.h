//
//  VOKScriptForFolder.h
//  XcodeAutoBasher
//
//  Created by Ellen Shapiro (Vokal) on 9/18/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import "VOKProjectScriptFolderTreeObject.h"

@class VOKProjectContainer;

@interface VOKScriptForFolder : VOKProjectScriptFolderTreeObject

///The path to the file or folder to be monitored (relative path when within the same folder as the containing project, otherwise absolute path).
@property (nonatomic) NSString *pathToFolder;

///The path to the script which should run when a change occurs (relative path when within the same folder as the containing project, otherwise absolute path).
@property (nonatomic) NSString *pathToScript;

///The absolute path to the file or folder to be monitored.
@property (nonatomic, readonly) NSString *absolutePathToFolder;

///The absolute path to the script which should run when a change occurs.
@property (nonatomic, readonly) NSString *absolutePathToScript;

///Whether the folder being watched should also have any child directorys watched. 
@property (nonatomic) BOOL shouldRecurse;

///The project-container object that contains this script-for-folder.
@property (nonatomic, weak) VOKProjectContainer *containingProject;

/**
 * Runs the script. 
 */
- (BOOL)runScript;

/**
 *  Construct a script-for-folder item from a serialized dictionary.
 *
 *  @param dictionary The dictionary containing the requisite values
 *
 *  @return The constructed VOKScriptForFolder item
 */
+ (instancetype)scriptFromDictionary:(NSDictionary *)dictionary;

/**
 *  Serialize the receiver into a dictionary.
 *
 *  @return The dictionary containing the values in the receiver
 */
- (NSDictionary *)dictionaryFromScript;

/**
 *  Start monitoring the specified folder and triggering the script on changes.
 */
- (void)startWatching;

/**
 *  Stop monitoring the specified folder.
 */
- (void)stopWatching;

/**
 *  Remove the script-for-folder entirely.
 */
- (void)remove;

@end
