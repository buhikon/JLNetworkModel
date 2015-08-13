//
//  JLNetworkModel.h
//
//  Version 1.0.0
//
//  Created by Joey L. on 8/5/15.
//  Copyright (c) 2015 Joey L. All rights reserved.
//
// * 서브 클래스를 만들어서 사용
//    서브 클래스 규칙
//     1. API 규격과 똑같은 이름의 Property를 정의할 것
//     2. 숫자는 NSNumber를 쓸 것을 추천 (null 체크가 가능)
//
//  https://github.com/buhikon/JLNetworkModel
//
#import <Foundation/Foundation.h>

@interface JLNetworkModel : NSObject


/*!
 @abstract NSDictionary 값으로 객체를 초기화 한다. dictionary의 key와 같은 이름의 property에 자동으로  값이 저장된다.
 @param dict dictionary의 key값과 property의 이름이 같아야 한다.
 */
- (instancetype)initWithNetworkDict:(NSDictionary *)dict;

/*!
 @abstract convert the items of array (NSDictionary -> subclass of JLNetworkModel).
 @return convertedArray
 @param networkArray array of NSDictionary
 */
+ (NSMutableArray *)convertNetworkArray:(NSArray *)networkArray;

@end
