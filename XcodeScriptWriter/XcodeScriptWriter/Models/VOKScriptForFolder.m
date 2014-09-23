//
//  VOKScriptForFolder.m
//  XcodeScriptWriter
//
//  Created by Ellen Shapiro (Vokal) on 9/18/14.
//  Copyright (c) 2014 Vokal Interactive. All rights reserved.
//

#import "VOKScriptForFolder.h"

static NSString *const TopLevelFoldersKey = @"top_level_folders";
static NSString *const ScriptPathKey = @"script_path";
static NSString *const FolderPathKey = @"folder_path";
static NSString *const ShouldRecurseKey = @"should_recurse";
static NSString *const FolderName = @"XcodeScriptWriter";
static NSString *const PlistFileName = @"TopLevelWatchedFolders.plist";

@interface VOKScriptForFolder()
@property (nonatomic) NSTimer *multipleStopper;

@end

@implementation VOKScriptForFolder

#pragma mark - Loading and unloading zone

+ (NSString *)plistPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupport = [paths firstObject];
    
    NSString *pluginFolderPath = [applicationSupport stringByAppendingPathComponent:FolderName];
    
    //Create folder if needed
    if (![[NSFileManager defaultManager] fileExistsAtPath:pluginFolderPath]) {
        NSError *folderCreationError;
        [[NSFileManager defaultManager] createDirectoryAtPath:pluginFolderPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&folderCreationError];
        if (folderCreationError) {
            NSLog(@"Error creating folder %@: %@", pluginFolderPath, folderCreationError);
            return nil;
        }
    }
    
    NSString *plistPath = [pluginFolderPath stringByAppendingPathComponent:PlistFileName];
    return plistPath;
}

+ (NSArray *)folderObjectsFromPlist
{
    NSString *path = [self plistPath];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) {
        NSLog(@"No data found at path %@", path);
        return nil;
    }
    NSPropertyListFormat format;
    NSError *plistReadError = nil;
    NSDictionary *topLevelFolders = [NSPropertyListSerialization propertyListWithData:data
                                                                              options:0
                                                                               format:&format
                                                                                error:&plistReadError];
    
    if (plistReadError) {
        NSLog(@"Error reading in plist %@", plistReadError);
    }

    NSArray *folders = topLevelFolders[TopLevelFoldersKey];
    NSMutableArray *objectFolders = [NSMutableArray array];
    
    for (NSDictionary *folderDict in folders) {
        [objectFolders addObject:[self scriptFromDictionary:folderDict]];
    }
    
    return objectFolders;

}

+ (void)writeObjectsToPlist:(NSArray *)folderObjects
{
    NSMutableArray *dicts = [NSMutableArray array];
    for (VOKScriptForFolder *script in folderObjects) {
        [dicts addObject:[script dictionaryFromScript]];
    }
    
    NSDictionary *topLevelFolders = @{ TopLevelFoldersKey : dicts };
    NSString *plistErrorDescription = nil;
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:topLevelFolders
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&plistErrorDescription];
    if (!plistErrorDescription) {
        NSString *path = [self plistPath];
        [plistData writeToFile:path atomically:YES];
    } else {
        NSLog(@"Error creating plist: %@", plistErrorDescription);
    }
}

+ (instancetype)scriptFromDictionary:(NSDictionary *)dictionary
{
    VOKScriptForFolder *script = [[self alloc] init];
    script.pathToFolder = dictionary[FolderPathKey];
    script.pathToScript = dictionary[ScriptPathKey];
    script.shouldRecurse = [dictionary[ShouldRecurseKey] boolValue];
    return script;
}

- (NSDictionary *)dictionaryFromScript
{
    return @{
             ScriptPathKey: self.pathToScript ? self.pathToScript : @"",
             FolderPathKey: self.pathToFolder ? self.pathToFolder : @"",
             ShouldRecurseKey: @(self.shouldRecurse),
             };

}

#pragma mark - Running ye script

- (BOOL)runScript
{
    if (self.pathToScript) {
        [self.multipleStopper invalidate];
        self.multipleStopper = [NSTimer scheduledTimerWithTimeInterval:1
                                                                target:self
                                                              selector:@selector(actuallyRunScript)
                                                              userInfo:nil
                                                               repeats:NO];

        return YES;
    } else {
        return NO;
    }
}

- (void)actuallyRunScript
{
    NSString *scriptDir = [self.pathToScript stringByDeletingLastPathComponent];
    NSString *scriptFile = [self.pathToScript lastPathComponent];
    NSString *bashCommand = [NSString stringWithFormat:@"bash %@", scriptFile];
    [[self class] runCommand:bashCommand inDirectory:scriptDir];

}

+ (NSString *)runCommand:(NSString *)commandToRun inDirectory:(NSString *)currentDirectoryPath
{
    //Ganked from: http://stackoverflow.com/a/12310154/681493
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/bin/sh";
    task.currentDirectoryPath = currentDirectoryPath;
    task.arguments = @[ @"-c",
                        [NSString stringWithFormat:@"%@", commandToRun],
                        ];
    task.standardOutput = [NSPipe pipe];
    NSFileHandle *file = [[NSPipe pipe] fileHandleForReading];
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return output;
}

#pragma mark - Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"\nFolder: %@\nScript: %@\nShouldRecurse: %@", self.pathToFolder, self.pathToScript, self.shouldRecurse ? @"yes" : @"no"];
}

@end
