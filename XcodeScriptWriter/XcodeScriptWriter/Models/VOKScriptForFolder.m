//
//  VOKScriptForFolder.m
//  XcodeScriptWriter
//
//  Created by Ellen Shapiro (Vokal) on 9/18/14.
//  Copyright (c) 2014 Vokal Interactive. All rights reserved.
//

#import "VOKScriptForFolder.h"

static NSString *const ScriptPathKey = @"script_path";
static NSString *const FolderPathKey = @"folder_path";

@interface VOKScriptForFolder()
@property (nonatomic) NSTimer *multipleStopper;

@end

@implementation VOKScriptForFolder

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
