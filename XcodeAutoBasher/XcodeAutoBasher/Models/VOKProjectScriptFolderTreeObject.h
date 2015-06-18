//
//  VOKProjectScriptFolderTreeObject.h
//  XcodeAutoBasher
//
//  Created by Isaac Greenspan on 10/2/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VOKProjectScriptFolderTreeObject : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) BOOL isScriptForFolder;


@property (nonatomic, strong) NSMutableArray *topLevelFolderObjects;

///The path to the file or folder to be monitored (relative path when within the same folder as the containing project, otherwise absolute path).
@property (nonatomic, strong) NSString *pathToFolder;

///The path to the script which should run when a change occurs (relative path when within the same folder as the containing project, otherwise absolute path).
@property (nonatomic, strong) NSString *pathToScript;

///Whether the folder being watched should also have any child directories watched.
@property (nonatomic, assign) BOOL shouldRecurse;

@end
