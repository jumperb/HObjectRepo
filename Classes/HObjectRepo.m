//
//  HObjectRepo.m
//  MGModel
//
//  Created by zct on 2019/10/9.
//  Copyright © 2019 com.migu. All rights reserved.
//

#import "HObjectRepo.h"
#import <HAccess/NSObject+HDeserializable.h>
#import <Hodor/NSData+ext.h>
#import <Hodor/NSObject+ext.h>
#import <Hodor/NSFileManager+ext.h>

@interface HObjectRepo ()
@property (nonatomic) Class objClass;
@property (nonatomic) NSMutableDictionary *cache;
@property (nonatomic) BOOL hasLoadAll;
@end

@implementation HObjectRepo

- (instancetype)initWithObjClass:(Class)class cacheDir:(NSString *)cacheDir
{
    self = [super initWithCacheDir:cacheDir];
    if (self) {
        self.objClass = class;
        self.shouldEncodeKey = NO;
    }
    return self;
}
- (NSMutableDictionary *)cache {
    if (!_cache) _cache = [NSMutableDictionary new];
    return _cache;
}
- (id)objectForID:(NSString *)ID {
    NSObject *o = self.cache[ID];
    if (o) return o;
    
    NSData *data = [self dataForKey:ID];
    o = [self objectFromData:data];
    if (!o) {
        [self removeFileForKey:ID];
        return nil;
    }
    else {
        self.cache[ID] = o;
    }
    return o;
}
- (id)objectFromData:(NSData *)data {
    if (!data) return nil;
    NSDictionary *dict = [data JSONValue];
    if (!dict) {
        return nil;
    }
    NSObject *o = [self.objClass new];
    NSError *err = [o h_setWithDictionary:dict enableKeyMap:NO couldEmpty:YES];
    if (err) {
        NSAssert(NO, err.localizedDescription);
        return nil;
    }
    return o;
}
- (void)removeObjectForID:(NSString *)ID {
    [self.cache removeObjectForKey:ID];
    [self removeFileForKey:ID];
}
- (void)setObject:(id)o forID:(NSString *)ID {
    self.cache[ID] = o;
    NSData *data = [[o jsonString] dataUsingEncoding:NSUTF8StringEncoding];
    [self setData:data forKey:ID];
}
- (BOOL)objectExsitForID:(NSString *)ID {
    if (self.cache[ID]) return YES;
    return [self cacheExsitForKey:ID];
}
- (NSArray *)ids {
    return [self allFileNames];
}
- (NSArray *)all {
    if (!self.hasLoadAll) {
        NSMutableArray *objects = [NSMutableArray new];
        NSArray *files = [self ids];
        for (NSString *fileName in files) {
            NSString *filePath = [self.cacheDir stringByAppendingPathComponent:fileName];
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            NSObject *o = [self objectFromData:data];
            if (o) {
                [objects addObject:o];
                self.cache[o.ID] = o;
            }
            else {
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
        }
        return objects;
    }
    else {
        return self.cache.allValues;
    }
}

- (NSUInteger)count {
    return [self ids].count;
}
@end


@implementation NSObject (repo)
- (NSString *)ID {
    NSAssert(NO, @"必须实现ID");
    return nil;
}
+ (NSString *)p_classKey {
    return NSStringFromClass(self);
}
+ (HObjectRepo *)p_repo {
    
    static NSMutableDictionary<NSString*, HObjectRepo*> *repoMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        repoMap = [NSMutableDictionary new];
    });
    NSString *classKey = [self p_classKey];
    HObjectRepo *repo = repoMap[classKey];
    if (!repo) {
        NSString *path = [NSFileManager documentPath:[NSString stringWithFormat:@"object-repo/%@", classKey]];
        repo = [[HObjectRepo alloc] initWithObjClass:self cacheDir:path];
        repoMap[classKey] = repo;
    }
    return repo;
}
+ (instancetype)p_fromID:(NSString *)ID {
    return [[self p_repo] objectForID:ID];
}
+ (BOOL)p_exsit:(NSString *)ID {
    return [[self.class p_repo] objectExsitForID:ID];
}
+ (void)p_remove:(NSString *)ID {
    [[self p_repo] removeObjectForID:ID];
}
- (void)p_remove {
    [[self.class p_repo] removeObjectForID:self.ID];
}
- (void)p_save {
    [[self.class p_repo] setObject:self forID:self.ID];
}
+ (NSArray *)p_ids {
    return [[self p_repo] ids];
}
+ (NSArray *)p_all {
    return [[self p_repo] all];
}
+ (NSArray *)p_filter:(BOOL (^)(NSObject *obj))filter {
    NSArray *arr = [self p_all];
    if (!filter) return arr;
    NSMutableArray *res = [NSMutableArray new];
    for (NSObject *o in arr) {
        if (filter(o)) {
            [res addObject:o];
        }
    }
    return res;
}
+ (NSUInteger)p_count {
    return [[self p_repo] count];
}
@end
