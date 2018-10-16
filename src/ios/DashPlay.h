//
//  PlayerView.h
//  VBPlayerDemo
//
//  Created by Ivan Ermolaev on 6/18/15.
//  Copyright (c) 2015 Viblast. All rights reserved.
//

#import <Cordova/CDVPlugin.h>
#import "InterfaceView.h"

@interface DashPlay : CDVPlugin {
}

@property(nonatomic, strong) InterfaceView* myInterfaceView;

- (void)start: (CDVInvokedUrlCommand *) command;

@end
