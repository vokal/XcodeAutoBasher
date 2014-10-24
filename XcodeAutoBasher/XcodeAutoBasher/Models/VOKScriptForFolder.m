//
//  VOKScriptForFolder.m
//  XcodeAutoBasher
//
//  Created by Ellen Shapiro (Vokal) on 9/18/14.
//  Copyright (c) 2014 Vokal Interactive. All rights reserved.
//

#import "VOKScriptForFolder.h"

#import "VOKDirectoryWatcher.h"
#import "VOKProjectContainer.h"
#import "VOKLocalizedStrings.h"
#import <AppKit/AppKit.h>

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
        NSArray *subfolders = [self.containingProject.directoryWatcher allSubfoldersUnderPath:self.absolutePathToFolder];
        self.recursiveWatchers = [NSMutableArray arrayWithCapacity:[subfolders count]];
        for (NSString *subfolder in subfolders) {
            VOKScriptForFolder *subfolderScript = [[VOKScriptForFolder alloc] init];
            subfolderScript.pathToFolder = subfolder;
            subfolderScript.pathToScript = self.absolutePathToScript;
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
    [super setPathToFolder:[self.containingProject trimPathRelativeToProject:pathToFolder] ?: pathToFolder];
    [self.containingProject save];
    [self startWatching];
}

- (void)setPathToScript:(NSString *)pathToScript
{
    [self stopWatching];
    [super setPathToScript:[self.containingProject trimPathRelativeToProject:pathToScript] ?: pathToScript];
    [self.containingProject save];
    [self startWatching];
}

#pragma mark - readonly getters

- (NSString *)absolutePathToFolder
{
    if (!self.containingProject) {
        return self.pathToFolder;
    }
    NSURL *projectUrl = [NSURL fileURLWithPath:self.containingProject.containingPath];
    NSURL *folderUrl = [NSURL URLWithString:self.pathToFolder relativeToURL:projectUrl];
    return [folderUrl path];
}

- (NSString *)absolutePathToScript
{
    if (!self.containingProject) {
        return self.pathToScript;
    }
    NSURL *projectUrl = [NSURL fileURLWithPath:self.containingProject.containingPath];
    NSURL *scriptUrl = [NSURL URLWithString:self.pathToScript relativeToURL:projectUrl];
    return [scriptUrl path];
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
        self.multipleStopper = [NSTimer scheduledTimerWithTimeInterval:1.0f
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
    //Check if file is runnable or Xcode will crash
    if ([[NSFileManager defaultManager] isExecutableFileAtPath:self.absolutePathToScript]) {
        NSTask *task = [[NSTask alloc] init];
        task.launchPath = self.absolutePathToScript;
        task.currentDirectoryPath = [task.launchPath stringByDeletingLastPathComponent];
        [task launch];
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:[VOKLocalizedStrings ok]];
        [alert setMessageText:[VOKLocalizedStrings scriptNotExecutableTitle]];
        NSString *informative = [NSString stringWithFormat:[VOKLocalizedStrings scriptNotExecutableMessageFormat], [self.absolutePathToScript lastPathComponent], [VOKLocalizedStrings pluginName]];
        NSString *logoPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"xcab_logo" ofType:@"png"];
        NSImage *logoImage = [[NSImage alloc] initWithContentsOfFile:logoPath];
        [alert setIcon:logoImage];
        [alert setInformativeText:informative];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
    }
}

#pragma mark - Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"\nFolder: %@\nScript: %@\nShouldRecurse: %@", self.pathToFolder, self.pathToScript, self.shouldRecurse ? @"yes" : @"no"];
}

@end
