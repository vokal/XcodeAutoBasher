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
    return NSLocalizedString(@"Folder Path", @"Folder Path table header");
}

+ (NSString *)vok_scriptPath
{
    return NSLocalizedString(@"Script Path", @"Script path table header");
}

@end
