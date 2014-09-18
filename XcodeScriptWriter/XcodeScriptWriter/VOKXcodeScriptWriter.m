//
//  VOKXcodeScriptWriter.m
//  VOKXcodeScriptWriter
//
//  Created by Ellen Shapiro (Vokal) on 9/18/14.
//    Copyright (c) 2014 Vokal Interactive. All rights reserved.
//

#import "VOKXcodeScriptWriter.h"

#import "NSString+Localized.h"
#import "VOKDirectoryWatcher.h"
#import "VOKScriptForFolder.h"

static VOKXcodeScriptWriter *sharedPlugin;

@interface VOKXcodeScriptWriter() <VOKDirectoryWatcherDelegate>

@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, strong) NSMutableArray *folderObjects;

@end

@implementation VOKXcodeScriptWriter

#pragma mark - Plugin Lifecycle 

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
            sharedPlugin.folderObjects = [NSMutableArray array];
        });
    }
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource acccess
        self.bundle = plugin;
        
        // Create menu items, initialize UI, etc.

        // Sample Menu Item:
        [self setupMenuItem];
        [self loadExistingFolderWatchers];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setup

- (void)setupMenuItem
{
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Window"];
    if (menuItem) {
        NSMenu *subMenu = [menuItem submenu];
        [subMenu addItem:[NSMenuItem separatorItem]];
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:[NSString vok_pluginName]
                                                                action:@selector(doMenuAction)
                                                         keyEquivalent:@""];
        [actionMenuItem setTarget:self];
        [subMenu addItem:actionMenuItem];
    } else {
        NSLog(@"Menu item not found!");
    }
}

- (void)loadExistingFolderWatchers
{
    NSArray *folderObjects = [[NSUserDefaults standardUserDefaults] objectForKey:@"VOKXcodeScriptWriterObjects"];

    NSLog(@"Folder objects count: %@", @([folderObjects count]));
    
    if (![folderObjects count]) {
        //Hard code some shit for testing.
        VOKScriptForFolder *scripty = [[VOKScriptForFolder alloc] init];
        scripty.pathToFolder = [self desktopPath];
        scripty.pathToScript = [[self desktopPath] stringByAppendingPathComponent:@"Basher.sh"];
        [VOKDirectoryWatcher watchFolderWithPath:scripty.pathToFolder delegate:self];
        [self.folderObjects addObject:scripty];
    } else {
        //Add all the folders to the directory watcher.
        for (VOKScriptForFolder *scriptForFolder in folderObjects) {
            if ([scriptForFolder isKindOfClass:[VOKScriptForFolder class]]) {
                [self.folderObjects addObject:scriptForFolder];
                [VOKDirectoryWatcher watchFolderWithPath:scriptForFolder.pathToFolder delegate:self];
            } else {
                NSLog(@"WAIT! This isn't a folder, it's a %@!", NSStringFromClass([scriptForFolder class]));
            }
        }
    }
}

#pragma mark - Actions

// Sample Action, for menu item:
- (void)doMenuAction
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"CHECK YO CONSOLE" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
    [alert runModal];
}

- (void)fireScript:(VOKScriptForFolder *)script
{
    NSLog(@"FIRE SCRIPT AT %@", script.pathToScript);
}

#pragma mark - VOKDirectoryWatcherDelegate

- (void)directoryDidChange:(VOKDirectoryWatcher *)folderWatcher
{
    NSPredicate *changedFolderPredicate = [NSPredicate predicateWithFormat:@"%K == %@", NSStringFromSelector(@selector(pathToFolder)), folderWatcher.watchedPath];
    NSArray *found = [self.folderObjects filteredArrayUsingPredicate:changedFolderPredicate];
    
    if ([found count] == 1) {
        VOKScriptForFolder *script = [found firstObject];
        NSLog(@"Folder at %@ changed!", script.pathToFolder);
        [self fireScript:script];
    } else {
        NSLog(@"Found directory count is not 1, it is %@!", @([found count]));
    }
}

- (NSString *)desktopPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
    NSString *desktopPath = paths[0];
    return desktopPath;
}

@end
