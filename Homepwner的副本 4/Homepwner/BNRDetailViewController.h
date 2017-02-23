//
//  BNRDetailViewController.h
//  Homepwner
//
//  Created by leo on 2017/2/8.
//  Copyright © 2017年 leo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BNRItem;

@interface BNRDetailViewController : UIViewController

@property (nonatomic, strong) BNRItem *item;

- (instancetype) initForNewItem:(BOOL) isNew;

@property (nonatomic, copy) void (^dismissBlock)(void);

@end
