//
//  HWConfirmOrderModel.m
//  Community
//
//  Created by ryder on 8/3/15.
//  Copyright (c) 2015 caijingpeng. All rights reserved.
//

#import "HWConfirmOrderModel.h"

@implementation HWConfirmOrderModel

- (instancetype)initWithdictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.detail = [dictionary stringObjectForKey:@"detail"];
        self.key = [dictionary stringObjectForKey:@"key"];
        self.status = [dictionary stringObjectForKey:@"key"];
        self.data = [dictionary dictionaryObjectForKey:@"data"];
        
        self.addressId = [self.data stringObjectForKey:@"addressId"];
        self.address = [self.data stringObjectForKey:@"address"];
        self.goodsCount = [self.data stringObjectForKey:@"goodsCount"];
        self.goodsId = [self.data stringObjectForKey:@"goodsId"];
        self.goodsName = [self.data stringObjectForKey:@"goodsName"];
        self.mobile = [self.data stringObjectForKey:@"mobile"];
        self.name = [self.data stringObjectForKey:@"name"];
        self.orderAmount = [self.data stringObjectForKey:@"orderAmount"];
        self.orderCode = [self.data stringObjectForKey:@"orderCode"];
        self.orderCreateTime = [self.data stringObjectForKey:@"orderCreateTime"];
        self.orderId = [self.data stringObjectForKey:@"orderId"];
        self.orderStatus = [self.data stringObjectForKey:@"orderStatus"];
        self.releaseWarehouseTime  = [self.data stringObjectForKey:@"releaseWarehouseTime"];
        self.serverTime  = [self.data stringObjectForKey:@"serverTime"];
    }
    
    return self;
}

@end
