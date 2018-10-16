
#import "DashPlay.h"

#import <Cordova/CDVAvailability.h>

@implementation DashPlay

- (void)pluginInitialize {
}

- (void)start: (CDVInvokedUrlCommand *) command 
{
    
    NSString* url = [command.arguments objectAtIndex:0];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.myInterfaceView = [[InterfaceView alloc] initWithFrame:[UIScreen mainScreen].bounds str:url];
        UIViewController* rootVC = (UIViewController*) [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        [rootVC.view addSubview:self.myInterfaceView];

    });

    
    
    
}

@end
