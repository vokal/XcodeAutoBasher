//
//  VOKProjectContainer.h
//  XcodeAutoBasher
//
//  Created by Isaac Greenspan on 10/2/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import "VOKProjectScriptFolderTreeObject.h"

@protocol VOK_PBXProject;
@class VOKDirectoryWatcher;

@interface VOKProjectContainer : VOKProjectScriptFolderTreeObject

@property (nonatomic, strong) id<VOK_PBXProject> pbxProject;

@property (nonatomic, strong) VOKDirectoryWatcher *directoryWatcher;

/**
 *  The path to the project file-bundle
 */
@property (nonatomic, readonly) NSString *path;

/**
 *  The path to the directory containing the project file-bundle
 */
@property (nonatomic, readonly) NSString *containingPath;

/**
 *  The project's name, as determined by the project file-bundle's filename
 */
@property (nonatomic, readonly) NSString *name;

/**
 *  The build environment variables, as reported by `xcodebuild -showBuildSettings`, as an NSDictionary suitable for
 *  use as an NSTask's environment property.
 *
 *  Note that this runs `xcodebuild` synchronously, so it's probably a bad idea to call it on the main thread.
 */
@property (nonatomic, readonly) NSDictionary *environmentVariables;

- (instancetype)initWithPbxProject:(id<VOK_PBXProject>)pbxProject;

- (void)save;

/**
 *  @param absolutePath An absolute path to trim to be relative to the project, if it's within the project.
 *
 *  @return The given absolute path if it's outside the project, otherwise a path trimmed to be relative to the project.
 */
- (NSString *)trimPathRelativeToProject:(NSString *)absolutePath;

@end

@protocol VOK_PBXProject <NSObject>

- (NSString *)path;

@end
