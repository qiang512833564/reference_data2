//
//  HWCommondityModel.m
//  Community
//
//  Created by ryder on 7/31/15.
//  Copyright (c) 2015 caijingpeng. All rights reserved.
//

#import "HWCommondityModel.h"

@implementation HWCommondityModel

- (instancetype)initWithdictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        self.bigImg = [dictionary stringObjectForKey:@"bigImg"];
        self.orderBigImg = [dictionary stringObjectForKey:@"orderBigImg"];
        self.brand = [dictionary stringObjectForKey:@"brand"];
        self.brandUrl = [dictionary stringObjectForKey:@"brandUrl"];
        self.buyGoodsCount = [dictionary stringObjectForKey:@"buyGoodsCount"];
        self.costPrice = [dictionary stringObjectForKey:@"costPrice"];
        self.createTime = [dictionary stringObjectForKey:@"createTime"];
        self.creater = [dictionary stringObjectForKey:@"creater"];
        self.currentTime = [dictionary stringObjectForKey:@"currentTime"];
        self.disabled = [dictionary stringObjectForKey:@"disabled"];
        self.endTime  = [dictionary stringObjectForKey:@"endTime"];
        self.freePostageAmount = [dictionary stringObjectForKey:@"freePostageAmount"];
        self.freePostageNum = [dictionary stringObjectForKey:@"freePostageNum"];
        self.freePostageType = [dictionary stringObjectForKey:@"freePostageType"];
        self.goodsId  = [dictionary stringObjectForKey:@"goodsId"];
        self.goodsInfo  = [dictionary stringObjectForKey:@"goodsInfo"];
        self.goodsName = [dictionary stringObjectForKey:@"goodsName"];
        self.goodsRemark = [dictionary stringObjectForKey:@"goodsRemark"];
        self.isAuthBuy = [dictionary stringObjectForKey:@"isAuthBuy"];
        self.limitCount = [dictionary stringObjectForKey:@"limitCount"];
        self.marketPrice = [dictionary stringObjectForKey:@"marketPrice"];
        self.modifier = [dictionary stringObjectForKey:@"modifier"];
        self.modifyTime = [dictionary stringObjectForKey:@"modifyTime"];
        self.orderImg = [dictionary stringObjectForKey:@"orderImg"];
        self.postage = [dictionary stringObjectForKey:@"postage"];
        self.reduceStockType = [dictionary stringObjectForKey:@"reduceStockType"];
        self.sellPrice = [dictionary stringObjectForKey:@"sellPrice"];
        self.showDistanceEndTime = [dictionary stringObjectForKey:@"showDistanceEndTime"];
        self.showDistanceStartTime = [dictionary stringObjectForKey:@"showDistanceStartTime"];
        self.showSurplus = [dictionary stringObjectForKey:@"showSurplus"];
        self.smallImg = [dictionary stringObjectForKey:@"smallImg"];
        self.startTime = [dictionary stringObjectForKey:@"startTime"];
        self.status = [dictionary stringObjectForKey:@"status"];
        self.stock = [dictionary stringObjectForKey:@"stock"];
        self.surplusStock = [dictionary stringObjectForKey:@"surplusStock"];
        self.version = [dictionary stringObjectForKey:@"version"];
    }
    return self;
}

@end

/*
 返回参数说明：
 goodsId：商品id
 goodsName：商品名称
 goodsRemark：商品描述
 goodsInfo：商品简介
 bigImg：app显示的商品列表图片
 marketPrice：市场参考价
 sellPrice：出售价格
 showDistanceEndTime：是否显示剩余倒计时(0:否 1：是)
 showDistanceStartTime：是否显示开始倒计时(0:否 1：是)
 startTime：开始上架时间
 endTime：下架时间
 currentTime：当前后台服务器系统时间
 isAuthBuy：是否认证购买 (0:否 1：是)
 buyGoodsCount：已经售出数量
 status：当前商品状态(0即将开始,1进行中,2已售完，3已下架，4未知状态)
 surplusStock：剩余库存
 */
