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
#import "VOKScriptWriterWindowController.h"

static VOKXcodeScriptWriter *sharedPlugin;

@interface VOKXcodeScriptWriter() <VOKDirectoryWatcherDelegate, VOKScriptWriterWindowDelegate>

@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, strong) NSMutableArray *folderObjects;
@property (nonatomic, strong) VOKScriptWriterWindowController *windowController;

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
            [[VOKDirectoryWatcher sharedInstance] setDelegate:sharedPlugin];
        });
    }
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource acccess
        _bundle = plugin;
        _folderObjects = [NSMutableArray array];

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
                                                                action:@selector(showEditWindow)
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
        [[VOKDirectoryWatcher sharedInstance] watchFolderWithPath:scripty.pathToFolder];
        [self.folderObjects addObject:scripty];
    } else {
        //Add all the folders to the directory watcher.
        for (VOKScriptForFolder *scriptForFolder in folderObjects) {
            if ([scriptForFolder isKindOfClass:[VOKScriptForFolder class]]) {
                [self.folderObjects addObject:scriptForFolder];
                [[VOKDirectoryWatcher sharedInstance] watchFolderWithPath:scriptForFolder.pathToFolder];
            } else {
                NSLog(@"WAIT! This isn't a folder, it's a %@!", NSStringFromClass([scriptForFolder class]));
            }
        }
    }
}

#pragma mark - Actions

- (void)showEditWindow
{
    if (!self.windowController) {
        self.windowController = [[VOKScriptWriterWindowController alloc] initWithBundle:self.bundle andArray:self.folderObjects];
        self.windowController.delegate = self;
    }
    
    NSLog(@"Window controller %@", self.windowController);
    
    [[self.windowController window] makeKeyAndOrderFront:self];
}

#pragma mark - VOKDirectoryWatcherDelegate

- (void)directoryDidChange:(NSString *)path
{
    NSPredicate *changedFolderPredicate = [NSPredicate predicateWithFormat:@"%K == %@", NSStringFromSelector(@selector(pathToFolder)), path];
    NSArray *found = [self.folderObjects filteredArrayUsingPredicate:changedFolderPredicate];
    
    if ([found count] == 1) {
        VOKScriptForFolder *script = [found firstObject];
        [script runScript];
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

#pragma mark - VOKScriptWriterWindowDelegate

- (void)addScript:(VOKScriptForFolder *)scriptToAdd
{
    [[VOKDirectoryWatcher sharedInstance] watchFolderWithPath:scriptToAdd.pathToFolder];
}

- (void)removeScript:(VOKScriptForFolder *)scriptToRemove
{
    [[VOKDirectoryWatcher sharedInstance] stopWatchingFolderWithPath:scriptToRemove.pathToFolder];
}

@end
