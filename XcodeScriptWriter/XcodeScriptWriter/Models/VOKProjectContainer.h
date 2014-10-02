//
//  VOKProjectContainer.h
//  XcodeScriptWriter
//
//  Created by Isaac Greenspan on 10/2/14.
//  Copyright (c) 2014 Vokal Interactive. All rights reserved.
//

#import "VOKProjectScriptFolderTreeObject.h"

@protocol VOK_PBXProject;
@class VOKDirectoryWatcher;

@interface VOKProjectContainer : VOKProjectScriptFolderTreeObject

@property (nonatomic, strong) id<VOK_PBXProject> pbxProject;

@property (nonatomic, strong) VOKDirectoryWatcher *directoryWatcher;

@property (nonatomic, readonly) NSString *path;
@property (nonatomic, readonly) NSString *name;

@property (nonatomic, strong) NSMutableArray *topLevelFolderObjects;

- (instancetype)initWithPbxProject:(id<VOK_PBXProject>)pbxProject;

- (void)save;

@end

@protocol VOK_PBXProject <NSObject>

- (NSString *)path;

@end
