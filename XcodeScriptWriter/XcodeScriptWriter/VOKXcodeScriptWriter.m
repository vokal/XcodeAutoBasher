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
#import "VOKProjectContainer.h"
#import "VOKScriptForFolder.h"
#import "VOKScriptWriterWindowController.h"

static VOKXcodeScriptWriter *sharedPlugin;

@interface VOKXcodeScriptWriter()

@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, strong) NSMutableArray *folderObjects;
@property (nonatomic, strong) VOKScriptWriterWindowController *windowController;

@property (nonatomic, strong) NSMutableDictionary *projects;

@end

static NSString *const PBXProjectDidOpenNotification = @"PBXProjectDidOpenNotification";
static NSString *const PBXProjectWillCloseNotification = @"PBXProjectWillCloseNotification";

@implementation VOKXcodeScriptWriter

#pragma mark - Plugin Lifecycle 

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
//            [[VOKDirectoryWatcher sharedInstance] setDelegate:sharedPlugin];
        });
    }
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource acccess
        _bundle = plugin;
        _folderObjects = [NSMutableArray array];
        
        _projects = [NSMutableDictionary dictionary];

        // Create menu items, initialize UI, etc.
		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didOpenProject:)
                                                     name:PBXProjectDidOpenNotification
                                                   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willCloseProject:)
                                                     name:PBXProjectWillCloseNotification
                                                   object:nil];

        // Sample Menu Item:
        [self setupMenuItem];
    }
    return self;
}

- (void)didOpenProject:(NSNotification *)projectNotification
{
    id<VOK_PBXProject> project = [projectNotification object];
    VOKProjectContainer *projectContainer = [[VOKProjectContainer alloc] initWithPbxProject:project];
    self.projects[projectContainer.path] = projectContainer;
    for (VOKScriptForFolder *scriptForFolder in projectContainer.topLevelFolderObjects) {
        [scriptForFolder startWatching];
    }
    self.windowController.projects = [self.projects allValues];
}

- (void)willCloseProject:(NSNotification *)projectNotification
{
    id<VOK_PBXProject> project = [projectNotification object];
    if ([project respondsToSelector:@selector(path)]) {
        NSString *projectPath = [project path];
        VOKProjectContainer *projectContainer = self.projects[projectPath];
//        NSLog(@"-=> removing items: %@", self.topLevelFolderObjectsByProject[projectPath]);
        for (VOKScriptForFolder *scriptForFolder in projectContainer.topLevelFolderObjects) {
            [scriptForFolder stopWatching];
        }
        [self.projects removeObjectForKey:projectPath];
    }
    self.windowController.projects = [self.projects allValues];
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

#pragma mark - Actions

- (void)showEditWindow
{
    if (!self.windowController) {
        self.windowController = [[VOKScriptWriterWindowController alloc] initWithBundle:self.bundle];
        self.windowController.projects = [self.projects allValues];
    }
    
    [[self.windowController window] makeKeyAndOrderFront:self];
}

@end
