//
//  BNRImageStore.h
//  Homepwner
//
//  Created by leo on 2017/2/10.
//  Copyright © 2017年 leo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BNRImageStore : NSObject

+ (instancetype) sharedStore;
- (void) setImage: (UIImage *) image forKey: (NSString *) key;
- (UIImage *) imageforKey: (NSStirng *) key;
- (void) deleteImageForKey: (NSString *)key;

@end
