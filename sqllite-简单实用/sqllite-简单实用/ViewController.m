//
//  ViewController.m
//  sqllite-简单实用
//
//  Created by 陈栋 on 16/3/25.
//  Copyright © 2016年 man. All rights reserved.
//

#import "ViewController.h"
#import <sqlite3.h>

@interface ViewController ()

@property (nonatomic,assign) sqlite3 *db;

@end

@implementation ViewController


- (IBAction)insert:(id)sender {
    NSLog(@"%s",__func__);
    
    NSString *sql = @"insert into t_student (name,age) values('cd',15);";
    
    char *errmsg;
    sqlite3_exec(self.db, sql.UTF8String, NULL, NULL, &errmsg);
    
    if (errmsg) {
         NSLog(@"插入数据失败！%s",errmsg);
    }else{
        NSLog(@"插入数据成功！");
    }
    
}


- (IBAction)select:(id)sender {
     NSLog(@"%s",__func__);
    
    
    NSString *sql = @"select * from t_student;";
    
    //OUT: Statement handle
    sqlite3_stmt *stmt;
    
    //句柄
    if (sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL)==SQLITE_OK) {
        while (sqlite3_step(stmt)==SQLITE_ROW) {//成功获取一条数据
            int stuId = sqlite3_column_int(stmt, 0);
            NSString *name = [NSString stringWithUTF8String:sqlite3_column_text(stmt, 1)];
            int age = sqlite3_column_int(stmt, 2);
            
            NSLog(@"%d,%@,%d",stuId,name,age);
        }
    }

}

- (IBAction)update:(id)sender {
    NSLog(@"%s",__func__);
    
    NSString *sql = @"update t_student set age = 24  where name='cd' ";
    
    char *errmsg;
    sqlite3_exec(self.db, sql.UTF8String, NULL, NULL, &errmsg);
    
    if (errmsg) {
        NSLog(@"update数据失败！%s",errmsg);
    }else{
        NSLog(@"update数据成功！");
    }
}

- (IBAction)delte:(id)sender {
    NSLog(@"%s",__func__);
    
    NSString *sql = @"delete from t_student" ;
    
    char *errmsg;
    sqlite3_exec(self.db, sql.UTF8String, NULL, NULL, &errmsg);
    
    if (errmsg) {
        NSLog(@"delete数据失败！%s",errmsg);
    }else{
        NSLog(@"delte 数据成功！");
    }
}



/**
 *封装 sql执行器
 *
 *  @param sql  要执行的sql语句
 *
 *  @return errmsg 错误信息
 */
- (char *) exeSql:(NSString *)sql
{
    char *errmsg;
    sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &errmsg);
    return errmsg;

}











- (void)viewDidLoad {
    [super viewDidLoad];
   
    //文件路径
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
     NSString *fileNmae = [path stringByAppendingPathComponent:@"student_v2.sqlite"];
    NSLog(@"%@",fileNmae);
    //定义数据库指针
    sqlite3 *db = nil;
    /**
     *  sqlite3_open  
        参数一:数据库文件名称
        参数二:指向数据库指针的地址  sqlite3 **ppDb   **表示指针的地址
     */
    if (sqlite3_open(fileNmae.UTF8String, &db)==SQLITE_OK) {
        NSLog(@"数据库成功打开!");
        NSString *sql = @"create table if not exists t_student (id integer primary key autoincrement,name text not null,age integer not null)";
        // 创建表格
        char *errmsg;
        /**
         *  参数一:一个打开了的数据库
            参数二:待执行的sql语句
            参数三,参数四  回调指向  暂时不使用
            参数五:错误信息 指针地址
         */
        sqlite3_exec(db, sql.UTF8String, NULL, NULL, &errmsg);
        if (errmsg) {//有错误信息
            NSLog(@"sql创建表格失败错误:%s",errmsg);
        }else{
            NSLog(@"创建表格成功");
        }
        
        _db = db;
    }else{
        NSLog(@"数据库成打开失败!");
    }


}



@end
