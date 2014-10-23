//
//  VOKProjectContainer.m
//  XcodeScriptWriter
//
//  Created by Isaac Greenspan on 10/2/14.
//  Copyright (c) 2014 Vokal Interactive. All rights reserved.
//

#import "VOKProjectContainer.h"

#import "VOKDirectoryWatcher.h"
#import "VOKScriptForFolder.h"

@interface VOKProjectContainer () <VOKDirectoryWatcherDelegate>

@property (nonatomic, readonly) NSString *watchesFilePath;

@end

static NSString *const PlistExtension = @"XcSW.plist";

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

#pragma mark - VOKDirectoryWatcherDelegate methods

- (void)directoryDidChange:(NSString *)path
{
    NSPredicate *changedFolderPredicate = [NSPredicate predicateWithFormat:@"%@ BEGINSWITH %K",
                                           path, NSStringFromSelector(@selector(absolutePathToFolder))];
    NSArray *found = [self.topLevelFolderObjects filteredArrayUsingPredicate:changedFolderPredicate];
    if (![found count]) {
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
