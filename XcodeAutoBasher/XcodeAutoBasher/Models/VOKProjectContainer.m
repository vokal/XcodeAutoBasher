//
//  VOKProjectContainer.m
//  XcodeAutoBasher
//
//  Created by Isaac Greenspan on 10/2/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import "VOKProjectContainer.h"

#import "VOKDirectoryWatcher.h"
#import "VOKScriptForFolder.h"

@interface VOKProjectContainer () <VOKDirectoryWatcherDelegate>

@property (nonatomic, readonly) NSString *watchesFilePath;

@end

static NSString *const PlistExtension = @"XcAB.plist";

@implementation VOKProjectContainer

- (instancetype)initWithPbxProject:(id<VOK_PBXProject>)pbxProject
{
    self = [super init];
    if (self) {
        _pbxProject = pbxProject;
        [self loadWatches];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ (%p): %@, %@ script-for-folders>",
            NSStringFromClass([self class]), self,
            self.name, @([self.topLevelFolderObjects count])];
}

- (NSString *)trimPathRelativeToProject:(NSString *)absolutePath
{
    NSString *projectDirectoryPath = [self.containingPath stringByAppendingString:@"/"];
    if (![absolutePath hasPrefix:projectDirectoryPath]) {
        return absolutePath;
    }
    return [absolutePath substringFromIndex:projectDirectoryPath.length];
}

#pragma mark - load/save

- (void)loadWatches
{
    NSString *plistPath = self.watchesFilePath;
    if (plistPath) {
        NSArray *items = [NSArray arrayWithContentsOfFile:plistPath];
//        NSLog(@"-=> adding items: %@", items);
        self.topLevelFolderObjects = [NSMutableArray array];
        for (NSDictionary *dict in items) {
            VOKScriptForFolder *scriptForFolder = [VOKScriptForFolder scriptFromDictionary:dict];
            scriptForFolder.containingProject = self;
            [self.topLevelFolderObjects addObject:scriptForFolder];
        }
    }
}

- (void)save
{
    NSString *plistPath = self.watchesFilePath;
    if (plistPath) {
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:[self.topLevelFolderObjects count]];
        for (VOKScriptForFolder *scriptForFolder in self.topLevelFolderObjects) {
            [items addObject:[scriptForFolder dictionaryFromScript]];
        }
        [items writeToFile:plistPath atomically:YES];
    }
}

#pragma mark - overridden setters/getters

- (NSString *)path
{
    if (![self.pbxProject respondsToSelector:@selector(path)]) {
        return nil;
    }
    return [self.pbxProject path];
}

- (NSString *)containingPath
{
    return [self.path stringByDeletingLastPathComponent];
}

- (NSString *)name
{
    return [[self.path lastPathComponent] stringByDeletingPathExtension];
}

- (NSString *)pathToFolder
{
    return [NSString stringWithFormat:@"%@ (%@)", self.name, self.containingPath];
}

- (NSString *)watchesFilePath
{
    return [[self.containingPath stringByAppendingPathComponent:self.name]
            stringByAppendingPathExtension:PlistExtension];
}

- (VOKDirectoryWatcher *)directoryWatcher
{
    if (!_directoryWatcher) {
        _directoryWatcher = [[VOKDirectoryWatcher alloc] init];
        _directoryWatcher.delegate = self;
    }
    return _directoryWatcher;
}

- (NSDictionary *)environmentVariables
{
    NSAssert(![NSThread isMainThread], @"VOKProjectContainer environmentVariables being retrieved on the main thread.");
    if ([NSThread isMainThread]) {
        NSLog(@"VOKProjectContainer environmentVariables being retrieved on the main thread.");
    }
    NSPipe *outputPipe = [NSPipe pipe];
    
    NSTask *buildSettingsTask = [[NSTask alloc] init];
    buildSettingsTask.launchPath = @"/usr/bin/xcodebuild";
    buildSettingsTask.currentDirectoryPath = self.containingPath;
    buildSettingsTask.arguments = @[ @"-showBuildSettings", ];
    buildSettingsTask.standardOutput = outputPipe;
    
    [buildSettingsTask launch];
    [buildSettingsTask waitUntilExit];
    
    NSData *outputData = [outputPipe.fileHandleForReading readDataToEndOfFile];
    NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:
                                  @"^[[:space:]]*([^[:space:]]*)[[:space:]]*=[[:space:]]*(.*)$"
                                  options:NSRegularExpressionAnchorsMatchLines
                                  error:&error];
    if (!regex) {
        NSLog(@"VOKProjectContainer error making regex: %@", error);
        return nil;
    }
    
    NSMutableDictionary *env = [NSMutableDictionary dictionary];
    [regex
     enumerateMatchesInString:outputString
     options:NSMatchingReportProgress
     range:NSMakeRange(0, outputString.length)
     usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
         if (result.numberOfRanges != 3) {
             return;
         }
         id key = [outputString substringWithRange:[result rangeAtIndex:1]];
         id value = [outputString substringWithRange:[result rangeAtIndex:2]];
         env[key] = value;
     }];
    return [env copy];
}

#pragma mark - VOKDirectoryWatcherDelegate methods

- (void)directoryDidChange:(NSString *)path
{
    NSPredicate *changedFolderPredicate = [NSPredicate predicateWithFormat:@"%@ BEGINSWITH %K",
                                           path, NSStringFromSelector(@selector(absolutePathToFolder))];
    NSArray *found = [self.topLevelFolderObjects filteredArrayUsingPredicate:changedFolderPredicate];
    if (!found.count) {
        NSLog(@"Found no paths matching %@ in %@.", path, self.name);
        return;
    }
    
    VOKScriptForFolder *bestMatch = nil;
    for (VOKScriptForFolder *match in found) {
        if (match.absolutePathToFolder.length > bestMatch.absolutePathToFolder.length) {
            bestMatch = match;
        }
    }
    [bestMatch runScript];
}

@end
