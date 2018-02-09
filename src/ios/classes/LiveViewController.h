//
//  LiveViewController.h
//  Fitbase
//
//  Created by Karthikeyan on 28/12/17.
//

#import <UIKit/UIKit.h>
#import <Opentok/Opentok.h>

@interface LiveViewController : UIViewController

@property (nonatomic,strong) NSString * openTokApi_Key;
@property (nonatomic,strong) NSString * openTokSessionID;
@property (nonatomic,strong) NSString * openTokToken;
@property (nonatomic,strong) NSDictionary * hybridParams;
@end
