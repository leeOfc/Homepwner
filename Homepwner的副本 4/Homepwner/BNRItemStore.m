//
//  BNRItemStore.m
//  Homepwner
//
//  Created by leo on 2016/12/18.
//  Copyright © 2016年 leo. All rights reserved.
//

#import "BNRItemStore.h"
#import "BNRImageStore.h"
#import "BNRItem.h"

@interface BNRItemStore()

@property (nonatomic) NSMutableArray *privateItems;

@end

@implementation BNRItemStore

+(instancetype)sharedStore
{
    static BNRItemStore *sharedStore = nil;
    //判断是否需要创建一个sharedStore对象
    if (!sharedStore) {
        sharedStore = [[self alloc]initPrivate];
    }
    
    return sharedStore;
}

//如果调用[[BNRItemStore alloc] init],就提示应该使用[BNRItemStore sharedStore]
-(instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[BNRItemStore sharedStore"
                                 userInfo:nil];
}

//这才是真正的私有化方法
-(instancetype)initPrivate
{
    self = [super init];
    
    if (self) {
        _privateItems = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (BNRItem *)createItem
{
    BNRItem *item = [BNRItem randomItem];
    [self.privateItems addObject:item];
    return item;
}

-
(NSArray *)allItems //编译器不会给他生成取方法和实例方法的， readonly！！
{
    return self.privateItems;
}

-(void) moveItemAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    if (fromIndex == toIndex) {
        return;
    }
    //得到要移动的对象的指针，以便稍后能将其插入新的位置
    BNRItem *item = self.privateItems[fromIndex];
    //将item从allItems数组中移出
    [self.privateItems removeObjectAtIndex:fromIndex];
    //根据新的索引位置，将item插回allItems数组
    [self.privateItems insertObject:item atIndex:toIndex];
    
}

-(void)removeItem:(BNRItem *)item
{
    NSString *key = item.itemKey;
    [[BNRImageStore sharedStore] deleteImageForKey:key];
    [self.privateItems removeObjectIdenticalTo:item];
}

@end
