//
//  VOKScriptWriterWindowController.h
//  XcodeScriptWriter
//
//  Created by Ellen Shapiro (Vokal) on 9/18/14.
//  Copyright (c) 2014 Vokal Interactive. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VOKScriptWriterWindowController : NSWindowController

@property (nonatomic, strong) NSArray *projects;

/**
 *  Designated initializer
 *
 *  @param bundle  The bundle for the plugin
 *
 *  @return the initialized instance. 
 */
- (id)initWithBundle:(NSBundle *)bundle;

@end
