//
//  ViewController.m
//  FMDB线程安全与事物
//
//  Created by 陈栋 on 16/3/25.
//  Copyright © 2016年 man. All rights reserved.
//

#import "ViewController.h"
#import "FMDB.h"

@interface ViewController ()

@property (nonatomic,strong) FMDatabaseQueue *queue;

@end

@implementation ViewController



- (IBAction)delete:(id)sender {
    [_queue inDatabase:^(FMDatabase *db) {
        BOOL flag = [db executeUpdate:@"delete from t_user;"];
        if (flag) {
            NSLog(@"success");
        }else{
            NSLog(@"failure");
        }
        
    }];
}
- (IBAction)add:(id)sender {
    
    [_queue inDatabase:^(FMDatabase *db) {
        
        BOOL flag = [db executeUpdate:@"insert into t_user (name,money) values (?,?)",@"a",@1000];
        if (flag) {
            NSLog(@"success");
        }else{
            NSLog(@"failure");
        }
        
        [db executeUpdate:@"insert into t_user (name,money) values (?,?)",@"b",@500];
        
    }];
    
}
- (IBAction)update:(id)sender {
    // update t_user set money = 500 where name = 'a';
    //  update t_user set money = 1000 where name = 'b';
    // a -> b 500 a 500
    // b + 500 = b 1000
    
    
    [_queue inDatabase:^(FMDatabase *db) {
        
        // 开启事务
        [db beginTransaction];
        BOOL flag = [db executeUpdate:@"update t_user set money = ? where name = ?;",@500,@"a"];
        if (flag) {
            NSLog(@"success");
        }else{
            NSLog(@"failure");
            // 回滚
            [db rollback];
        }
        
        BOOL flag1 = [db executeUpdate:@"updat t_user set money = ? where name = ?;",@1000,@"b"];
        if (flag1) {
            NSLog(@"success");
        }else{
            NSLog(@"failure");
            [db rollback];
        }
        
        // 全部操作完成时候再去
        [db commit];
    }];
    
}
- (IBAction)select:(id)sender {
    
    [_queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *result =   [db executeQuery:@"select * from t_user"];
        
        while ([result next]) {
            NSString *name = [result stringForColumn:@"name"];
            int money = [result intForColumn:@"money"];
            NSLog(@"%@--%d",name,money);
        }
        
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
   
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    // 拼接文件名
    NSString *filePath = [cachePath stringByAppendingPathComponent:@"user.sqlite"];
    
    //创建数据库实例  创建时候已经打开数据库
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:filePath];
    _queue = queue;
    
    // 创建数据库表
    // 提供了一个多线程安全的数据库实例
    [queue inDatabase:^(FMDatabase *db) {
        BOOL flag =  [db executeUpdate:@"create table if not exists t_user (id integer primary key autoincrement,name text,money integer)"];
        
        if (flag) {
            NSLog(@"success");
        }else{
            NSLog(@"failure");
        }
        
    }];


}



@end
