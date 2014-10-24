//
//  VOKProjectScriptFolderTreeObject.h
//  XcodeAutoBasher
//
//  Created by Isaac Greenspan on 10/2/14.
//  Copyright (c) 2014 Vokal Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VOKProjectScriptFolderTreeObject : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) BOOL isScriptForFolder;
@property (nonatomic, strong) NSArray *topLevelFolderObjects;
@property (nonatomic, strong) NSString *pathToFolder;
@property (nonatomic, strong) NSString *pathToScript;
@property (nonatomic, assign) BOOL shouldRecurse;

@end
