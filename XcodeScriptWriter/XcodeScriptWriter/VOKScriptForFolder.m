//
//  VOKScriptForFolder.m
//  XcodeScriptWriter
//
//  Created by Ellen Shapiro (Vokal) on 9/18/14.
//  Copyright (c) 2014 Vokal Interactive. All rights reserved.
//

#import "VOKScriptForFolder.h"

static NSString *const ScriptPathKey = @"script_path";
static NSString *const FolderPathKey = @"folder_path";

@implementation VOKScriptForFolder

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _pathToFolder = [coder decodeObjectForKey:FolderPathKey];
        _pathToScript = [coder decodeObjectForKey:ScriptPathKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.pathToFolder forKey:FolderPathKey];
    [coder encodeObject:self.pathToScript forKey:ScriptPathKey];
}

@end
