//
//  NSString+Localized.m
//  XcodeScriptWriter
//
//  Created by Ellen Shapiro (Vokal) on 9/18/14.
//  Copyright (c) 2014 Vokal Interactive. All rights reserved.
//

#import "NSString+Localized.h"

@implementation NSString (Localized)

+ (NSString *)vok_pluginName
{
    return NSLocalizedString(@"XcodeScriptWriter", @"Name of plugin");
}

+ (NSString *)vok_folderPath
{
    return NSLocalizedString(@"Watch This File or Folder", @"Folder Path table header");
}

+ (NSString *)vok_scriptPath
{
    return NSLocalizedString(@"Run This Script", @"Script path table header");
}

+ (NSString *)vok_shouldRecurse
{
    return NSLocalizedString(@"Recursively?", @"Recursive checkbox table header");
}

@end
