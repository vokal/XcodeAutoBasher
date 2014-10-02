//
//  VOKScriptForFolder.m
//  XcodeScriptWriter
//
//  Created by Ellen Shapiro (Vokal) on 9/18/14.
//  Copyright (c) 2014 Vokal Interactive. All rights reserved.
//

#import "VOKScriptForFolder.h"

#import "VOKDirectoryWatcher.h"
#import "VOKProjectContainer.h"

static NSString *const ScriptPathKey = @"script_path";
static NSString *const FolderPathKey = @"folder_path";
static NSString *const ShouldRecurseKey = @"should_recurse";

@interface VOKScriptForFolder()

@property (nonatomic) NSTimer *multipleStopper;

@property (nonatomic) NSMutableArray *recursiveWatchers;

@end

@implementation VOKScriptForFolder

- (BOOL)isScriptForFolder
{
    return YES;
}

- (void)startWatching
{
    [self.containingProject.directoryWatcher watchFolder:self];
    if (self.shouldRecurse) {
        NSArray *subfolders = [self.containingProject.directoryWatcher allSubfoldersUnderPath:self.pathToFolder];
        self.recursiveWatchers = [NSMutableArray arrayWithCapacity:[subfolders count]];
        for (NSString *subfolder in subfolders) {
            VOKScriptForFolder *subfolderScript = [[VOKScriptForFolder alloc] init];
            subfolderScript.pathToFolder = subfolder;
            subfolderScript.pathToScript = self.pathToScript;
            [self.recursiveWatchers addObject:subfolderScript];
            [self.containingProject.directoryWatcher watchFolder:subfolderScript];
        }
    }
}

- (void)stopWatching
{
    [self.containingProject.directoryWatcher stopWatchingFolder:self];
    for (VOKScriptForFolder *subfolderScript in self.recursiveWatchers) {
        [self.containingProject.directoryWatcher stopWatchingFolder:subfolderScript];
    }
    self.recursiveWatchers = nil;
}

- (void)remove
{
    [self stopWatching];
    [self.containingProject.topLevelFolderObjects removeObject:self];
    [self.containingProject save];
}

#pragma mark - overridden setters

- (void)setShouldRecurse:(BOOL)shouldRecurse
{
    [self stopWatching];
    [super setShouldRecurse:shouldRecurse];
    [self.containingProject save];
    [self startWatching];
}

- (void)setPathToFolder:(NSString *)pathToFolder
{
    [self stopWatching];
    [super setPathToFolder:pathToFolder];
    [self.containingProject save];
    [self startWatching];
}

- (void)setPathToScript:(NSString *)pathToScript
{
    [self stopWatching];
    [super setPathToScript:pathToScript];
    [self.containingProject save];
    [self startWatching];
}

#pragma mark - Loading and unloading zone

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
             ScriptPathKey: self.pathToScript ?: @"",
             FolderPathKey: self.pathToFolder ?: @"",
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
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = self.pathToScript;
    task.currentDirectoryPath = [self.pathToScript stringByDeletingLastPathComponent];
    [task launch];
}

#pragma mark - Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"\nFolder: %@\nScript: %@\nShouldRecurse: %@", self.pathToFolder, self.pathToScript, self.shouldRecurse ? @"yes" : @"no"];
}

@end
