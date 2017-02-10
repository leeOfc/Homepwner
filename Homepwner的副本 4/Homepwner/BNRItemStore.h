//
//  BNRItemStore.h
//  Homepwner
//
//  Created by leo on 2016/12/18.
//  Copyright © 2016年 leo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BNRItem;

@interface BNRItemStore : NSObject

@property (nonatomic, readonly) NSArray *allItems;

//注意这是一个类方法
+(instancetype)sharedStore;

-(BNRItem *) createItem;

-(void) removeItem:(BNRItem *)item;
-(void) moveItemAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

@end
