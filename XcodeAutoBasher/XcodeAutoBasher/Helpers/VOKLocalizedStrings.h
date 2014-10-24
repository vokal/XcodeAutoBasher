//
//  VOKLocalizedStrings.h
//  XcodeAutoBasher
//
//  Created by Ellen Shapiro (Vokal) on 9/19/14.
//  Copyright (c) 2014 Vokal Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * Quick, autocompletable access to all user-facing strings.
 */
@interface VOKLocalizedStrings : NSObject

+ (NSString *)pluginName;
+ (NSString *)folderPath;
+ (NSString *)scriptPath;
+ (NSString *)shouldRecurse;
+ (NSString *)ok;
+ (NSString *)scriptNotExecutableTitle;
+ (NSString *)scriptNotExecutableMessageFormat;

@end
