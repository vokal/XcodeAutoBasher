//
//  VOKScriptWriterWindowController.h
//  XcodeScriptWriter
//
//  Created by Ellen Shapiro (Vokal) on 9/18/14.
//  Copyright (c) 2014 Vokal Interactive. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VOKScriptForFolder;

@protocol VOKScriptWriterWindowDelegate <NSObject>
@required
/**
 *  Called whenever a script is added through the UI and should be added to the watcher.
 *  @param scriptToAdd The top-level folder script to add.
 */
- (void)addScript:(VOKScriptForFolder *)scriptToAdd;

/**
 *  Called whenever a script is removed via the UI and should be removed from the watcher.
 *  @param scriptToRemove The top-level folder script to remove.
 */
- (void)removeScript:(VOKScriptForFolder *)scriptToRemove;

@end

@interface VOKScriptWriterWindowController : NSWindowController

///The delegate to notify 
@property (nonatomic, weak) id<VOKScriptWriterWindowDelegate>delegate;

/**
 *  Designated initializer
 *
 *  @param bundle  The bundle for the plugin
 *  @param scripts An array of VOKScriptForFolder objects.
 *
 *  @return the initialized instance. 
 */
- (id)initWithBundle:(NSBundle *)bundle andArray:(NSArray *)scripts;

@end
