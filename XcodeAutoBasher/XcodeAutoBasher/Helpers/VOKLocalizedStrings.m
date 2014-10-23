//
//  VOKLocalizedStrings.m
//  XcodeAutoBasher
//
//  Created by Ellen Shapiro (Vokal) on 9/19/14.
//  Copyright (c) 2014 Vokal Interactive. All rights reserved.
//

#import "VOKLocalizedStrings.h"

@implementation VOKLocalizedStrings

+ (NSString *)pluginName
{
    return NSLocalizedString(@"XcodeAutoBasher", @"Name of plugin");
}

+ (NSString *)folderPath
{
    return NSLocalizedString(@"Watch This File or Folder", @"Folder Path table header");
}

+ (NSString *)scriptPath
{
    return NSLocalizedString(@"Run This Script", @"Script path table header");
}

+ (NSString *)shouldRecurse
{
    return NSLocalizedString(@"Recursively?", @"Recursive checkbox table header");
}

@end
