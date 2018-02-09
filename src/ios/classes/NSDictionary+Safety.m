//
//  NSDictionary+Safety.m
//  Fitbase
//
//  Created by Karthikeyan on 28/12/17.
//

#import "NSDictionary+Safety.h"

@implementation NSDictionary (Safety)

- (id)safeObjectForKey:(id)aKey {
    NSObject *object = self[aKey];
    
    if (object == [NSNull null]) {
        return nil;
    }
    
    return object;
}

@end

