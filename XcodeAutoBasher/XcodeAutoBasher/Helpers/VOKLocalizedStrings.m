//
//  VOKLocalizedStrings.m
//  XcodeAutoBasher
//
//  Created by Ellen Shapiro (Vokal) on 9/19/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
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

+ (NSString *)ok
{
    return NSLocalizedString(@"OK", @"OK");
}

+ (NSString *)scriptNotExecutableTitle
{
    return NSLocalizedString(@"Script Not Executable", @"Title for alert when a script is not executable.");
}

+ (NSString *)scriptNotExecutableMessageFormat
{
    return NSLocalizedString(@"The script \"%1$@\" is not currently executable. Please make this file executable so %2$@ can run it.", @"Format with 2 placeholders for the script name and the plugin name for alert message when a script is not executable.");
}

@end
