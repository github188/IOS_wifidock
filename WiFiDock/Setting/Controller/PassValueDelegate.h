//
//  PassValueDelegate.h
//  WiFiDock
//
//  Created by hualu on 15-2-4.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UserEntity;

@protocol PassValueDelegate <NSObject>

-(void)passValue:(UserEntity *)value;

@end
