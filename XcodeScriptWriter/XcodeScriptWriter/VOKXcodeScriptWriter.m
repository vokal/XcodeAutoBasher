//
//  VOKXcodeScriptWriter.m
//  VOKXcodeScriptWriter
//
//  Created by Ellen Shapiro (Vokal) on 9/18/14.
//    Copyright (c) 2014 Vokal Interactive. All rights reserved.
//

#import "VOKXcodeScriptWriter.h"

#import "VOKLocalizedStrings.h"
#import "VOKDirectoryWatcher.h"
#import "VOKScriptForFolder.h"
#import "VOKScriptWriterWindowController.h"

static VOKXcodeScriptWriter *sharedPlugin;

@interface VOKXcodeScriptWriter() <VOKDirectoryWatcherDelegate, VOKScriptWriterWindowDelegate>

@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, strong) NSMutableArray *folderObjects;
@property (nonatomic, strong) NSMutableArray *topLevelFolderObjects;
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
        _topLevelFolderObjects = [NSMutableArray array];

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
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:[VOKLocalizedStrings pluginName]
                                                                action:@selector(showEditWindow)
                                                         keyEquivalent:@""];
        [actionMenuItem setTarget:self];
        [subMenu addItem:actionMenuItem];
    }
}

- (void)loadExistingFolderWatchers
{
    NSArray *folderObjects = [VOKScriptForFolder folderObjectsFromPlist];
    
    //Add all the folders to the directory watcher.
    for (VOKScriptForFolder *scriptForFolder in folderObjects) {
        if ([scriptForFolder isKindOfClass:[VOKScriptForFolder class]]) {
            [self addScript:scriptForFolder];
        }
    }
}

#pragma mark - Actions

- (void)showEditWindow
{
    if (!self.windowController) {
        self.windowController = [[VOKScriptWriterWindowController alloc] initWithBundle:self.bundle andArray:self.topLevelFolderObjects];
        self.windowController.delegate = self;
    }
    
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

#pragma mark - VOKScriptWriterWindowDelegate

- (void)addScript:(VOKScriptForFolder *)scriptToAdd
{
    [[VOKDirectoryWatcher sharedInstance] watchFolder:scriptToAdd];
    [self.folderObjects addObject:scriptToAdd];
    [self.topLevelFolderObjects addObject:scriptToAdd];
    [VOKScriptForFolder writeObjectsToPlist:self.topLevelFolderObjects];
    if (scriptToAdd.shouldRecurse) {
        NSArray *subfolders = [[VOKDirectoryWatcher sharedInstance] allSubfoldersUnderPath:scriptToAdd.pathToFolder];
        for (NSString *subfolder in subfolders) {
            VOKScriptForFolder *subfolderScript = [[VOKScriptForFolder alloc] init];
            subfolderScript.pathToFolder = subfolder;
            subfolderScript.pathToScript = scriptToAdd.pathToScript;
            [self.folderObjects addObject:subfolderScript];
        }
    }
}

- (void)removeScript:(VOKScriptForFolder *)scriptToRemove
{
    [[VOKDirectoryWatcher sharedInstance] stopWatchingFolder:scriptToRemove];
    [self.folderObjects removeObject:scriptToRemove];
    [self.topLevelFolderObjects removeObject:scriptToRemove];
    [VOKScriptForFolder writeObjectsToPlist:self.topLevelFolderObjects];
    if (scriptToRemove.shouldRecurse) {
        NSArray *subfolders = [[VOKDirectoryWatcher sharedInstance] allSubfoldersUnderPath:scriptToRemove.pathToFolder];
        for (NSString *subfolder in subfolders) {
            NSPredicate *subfolderPredicate = [NSPredicate predicateWithFormat:@"%K == %@", NSStringFromSelector(@selector(pathToFolder)), subfolder];
            NSArray *found = [self.folderObjects filteredArrayUsingPredicate:subfolderPredicate];
            VOKScriptForFolder *foundFolder = [found firstObject];
            [self.folderObjects removeObject:foundFolder];
        }
    }
}

@end
