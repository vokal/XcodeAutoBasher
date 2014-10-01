//
//  VOKScriptForFolder.h
//  XcodeScriptWriter
//
//  Created by Ellen Shapiro (Vokal) on 9/18/14.
//  Copyright (c) 2014 Vokal Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VOKScriptForFolder : NSObject

///The full path to the file or folder to be monitored.
@property (nonatomic) NSString *pathToFolder;

///The full path to the script which should run when a change occurs.
@property (nonatomic) NSString *pathToScript;

///Whether the folder being watched should also have any child directorys watched. 
@property (nonatomic) BOOL shouldRecurse;

/**
 * Runs the script. 
 */
- (BOOL)runScript;

/**
 *  Loads all the folder objects from a .plist stored in ~/Library/ApplicationSupport/XcodeScriptWriter.
 *  @return An array of the top-level folder objects being observed.
 */
+ (NSArray *)folderObjectsFromPlist;

/**
 *  Writes all the folder objects to a .plist stored in ~/Library/ApplicationSupport/XcodeScriptWriter.
 *  @param folderObjects An array of the top-level folder objects being observed.
 */
+ (void)writeObjectsToPlist:(NSArray *)folderObjects;

@end
