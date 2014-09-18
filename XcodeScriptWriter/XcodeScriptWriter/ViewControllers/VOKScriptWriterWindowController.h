//
//  VOKScriptWriterWindowController.h
//  XcodeScriptWriter
//
//  Created by Ellen Shapiro (Vokal) on 9/18/14.
//  Copyright (c) 2014 Vokal Interactive. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VOKScriptWriterWindowController : NSWindowController

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
