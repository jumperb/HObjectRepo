//
//  HObjectRepo.h
//  MGModel
//
//  Created by zct on 2019/10/9.
//  Copyright © 2019 com.migu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HCache/HFileCache.h>
NS_ASSUME_NONNULL_BEGIN

@interface HObjectRepo : HFileCache
- (instancetype)initWithObjClass:(Class)class cacheDir:(NSString *)cacheDir;
- (id)objectForID:(NSString *)ID;
- (void)setObject:(id)o forID:(NSString *)ID;
- (void)removeObjectForID:(NSString *)ID;
- (BOOL)objectExsitForID:(NSString *)ID;
- (NSArray *)ids;
- (NSUInteger)count;
@end

@interface NSObject (repo)
- (NSString *)ID;
+ (NSString *)p_classKey;
+ (instancetype)p_fromID:(NSString *)ID;
+ (BOOL)p_exsit:(NSString *)ID;
+ (void)p_remove:(NSString *)ID;
- (void)p_remove;
//存磁盘
- (void)p_save;
//全部id
+ (NSArray *)p_ids;
//全部
+ (NSArray *)p_all;
//返回NO，h过滤掉
+ (NSArray *)p_filter:(BOOL (^)(NSObject *obj))filter;
//总个数
+ (NSUInteger)p_count;
@end
NS_ASSUME_NONNULL_END
