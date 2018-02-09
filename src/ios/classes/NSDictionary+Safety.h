//
//  NSDictionary+Safety.h
//  Fitbase
//
//  Created by Karthikeyan on 28/12/17.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Safety)

- (id)safeObjectForKey:(id)aKey;

@end

