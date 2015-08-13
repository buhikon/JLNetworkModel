//
//  NetworkModel.m
//
//  Version 1.0.0
//
//  Created by Joey L. on 8/5/15.
//  Copyright (c) 2015 Joey L. All rights reserved.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

#import "NetworkModel.h"
#import <objc/runtime.h>

@implementation NetworkModel

- (instancetype)initWithNetworkDict:(NSDictionary *)networkDict
{
    self = [super init];
    if (self) {
        if (networkDict != nil) {
            
            NSDictionary *classProps = [self classProps];
            
            @try {
                NSEnumerator *enumerator = [networkDict keyEnumerator];
                id key = [enumerator nextObject];
                for ( ; key != nil; key = [enumerator nextObject]) {
                    @try {
                        id value = networkDict[key];
                        
                        // NSNull 체크
                        if([[value class] isSubclassOfClass:[NSNull class]]) {
                            value = nil;
                        }
                        
                        // 자료형 검사 (Local Property vs JSON via Network)
                        if(value) {
                            NSString *localPropsClassName = classProps[key];
                            NSString *networkPropsClassName = NSStringFromClass([value class]);
                            
                            NSAssert([self compareClassName:localPropsClassName withAnotherClassName:networkPropsClassName], @"%@ 값의 자료형이 다릅니다. 로컬데이터:%@, 통신데이터:%@", key, localPropsClassName, networkPropsClassName);
                        }
                        
                        // 값 세팅
                        if(value) {
                            [self setValue:value forKey:key];
                        }
                        
                    }
                    @catch(NSException *e) {
                        NSLog(@"Exception : %@", e);
                    }
                }
            }
            @catch(NSException *e) {
                NSLog(@"Exception : %@", e);
            }
        }
        
    }
    return self;
}

- (NSString *)description
{
    
    NSMutableString *s = [NSMutableString string];
    
    [s appendFormat:@"<%@: %lx", NSStringFromClass([self class]), (long)self];
    
    NSDictionary *classProps = [self classProps];
    NSArray *keys = classProps.allKeys;
    
    if(keys.count > 0) {
        for (NSString *key in keys) {
            id value = [self valueForKey:key];
            if(value) {
                [s appendFormat:@"; %@ = %@", key, value];
            }
        }
    }
    [s appendString:@">"];
    
    return s;
}

+ (NSMutableArray *)convertNetworkArray:(NSArray *)networkArray
{
    if(networkArray.count == 0) return nil;
    
    NSMutableArray *result = [NSMutableArray array];
    for (NSDictionary *networkDict in networkArray) {
        NetworkModel *model = [[[self class] alloc] initWithNetworkDict:networkDict];
        [result addObject:model];
    }
    
    return result;
}

#pragma mark - private methods

// 클래스명을 비교한다.
// NSString과 __NSCFString은 같은 클래스
// NSNumber과 __NSCFNumber은 같은 클래스
- (BOOL)compareClassName:(NSString *)name1 withAnotherClassName:(NSString *)name2
{
    NSArray *arr = @[@"Array", @"Dictionary", @"String", @"Number"];
    NSInteger index1 = 3;   // 모르는 클래스면 숫자로 취급
    NSInteger index2 = 3;    
    for(NSInteger i=0; i<arr.count; i++) {
        if([name1 rangeOfString:arr[i]].length > 0) {
            index1 = i;
            break;
        }
    }
    for(NSInteger i=0; i<arr.count; i++) {
        if([name2 rangeOfString:arr[i]].length > 0) {
            index2 = i;
            break;
        }
    }
    return index1 == index2;
}

#pragma mark - (work with properties)

static const char * getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
//    printf("attributes=%s\n", attributes);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            // it's a C primitive type:
            /*
             if you want a list of what will be returned for these primitives, search online for
             "objective-c" "Property Attribute Description Examples"
             apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.
             */
            return (const char *)[[NSData dataWithBytes:(attribute + 1) length:strlen(attribute) - 1] bytes];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // it's an ObjC id type:
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
        }
    }
    return "";
}


- (NSDictionary *)classProps
{
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            const char *propType = getPropertyType(property);
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            NSString *propertyType = [NSString stringWithUTF8String:propType];
            [results setObject:propertyType forKey:propertyName];
        }
    }
    free(properties);
    
    // returning a copy here to make sure the dictionary is immutable
    return [NSDictionary dictionaryWithDictionary:results];
}

@end
