//
//  BNRImageStore.m
//  Homepwner
//
//  Created by leo on 2017/2/10.
//  Copyright © 2017年 leo. All rights reserved.
//

#import "BNRImageStore.h"

@interface BNRImageStore()

@property (nonatomic, strong) NSMutableDictionary *dictionary;

@end

@implementation BNRImageStore

+(instancetype) sharedStore {
    static BNRImageStore *sharedStore = nil;
    if (! sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
                       return sharedStore;
}

- (instancetype) init {
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[BNRImageStore sharedStore]"
                                 userInfo:nil];
    return nil;
}

//创建私有化方法
- (instancetype) initPrivate{
    self = [super init];
    if (self) {
         _dictionary = [[NSMutableDictionary alloc]init];
            }
           return self;
                       }

- (void) setImage:(UIImage *)image forKey:(NSString *)key {
    //[self.dictionary setObject:image forKey:key];
    self.dictionary[key] = image;
}

- (UIImage *)imageforKey:(NSString *)key {
    //return [self.dictionary objectForKey:key];
    return self.dictionary[key];
}

-(void) deleteImageForKey:(NSString *)key {
    if (! key) {
        return ;
    }
    [self.dictionary removeObjectForKey:key];
}



@end

