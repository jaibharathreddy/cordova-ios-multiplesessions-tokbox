#import "ionicIosCommunication.h"
#import <Cordova/CDVPlugin.h>
#import <OpenTok/OpenTok.h>
#import "NSDictionary+Safety.h"
#import "LiveViewController.h"

@implementation ionicIosCommunication
    
- (void)coolMethod:(CDVInvokedUrlCommand*)command
    {
            NSDictionary* myarg = [command.arguments objectAtIndex:0];
            
            LiveViewController *viewController = [[LiveViewController alloc]initWithNibName:@"LiveViewController" bundle:nil];
            
            viewController.openTokApi_Key = [[myarg safeObjectForKey:@"apiKey"] stringValue];
            
            viewController.openTokSessionID = [myarg safeObjectForKey:@"liveSessionId"];
            
            viewController.openTokToken = [myarg safeObjectForKey:@"tokenId"];
            
            viewController.hybridParams = myarg;
            
            [self.viewController presentViewController:viewController animated:YES completion:nil];
    }
    
    @end
