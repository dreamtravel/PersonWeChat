//
//  WCContactController.m
//  WeChat
//
//  Created by Mac on 15/11/7.
//  Copyright © 2015年 Macmini. All rights reserved.
//

#import "WCContactController.h"

@interface WCContactController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *resultsController;

@end

@implementation WCContactController

- (void)loadUsers {
    // 显示好友数(保存在XMPPRoster.sqlite文件)
    // 1、上下文 关联XMPPRoster.sqlite文件
    NSManagedObjectContext *rosterContext = [WCXMPPTool sharedWCXMPPTool].rosterStoryage.mainThreadManagedObjectContext;
    // 2、Request 请求查询哪张表
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    //    设置排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sort];
    // 3、执行请求
    NSError *error = nil;
    //_contacts = [rosterContext executeFetchRequest:request error:&error];
    _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:rosterContext sectionNameKeyPath:nil cacheName:nil];
    _resultsController.delegate = self;
    [_resultsController performFetch:&error];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadUsers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.resultsController.fetchedObjects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"contact_cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    XMPPUserCoreDataStorageObject *model = self.resultsController.fetchedObjects[indexPath.row];
    cell.textLabel.text = model.jidStr;
    cell.imageView.image = model.photo;
    // 判断用户是否在线
    switch ([model.sectionNum integerValue]) {
        case 0:
            cell.detailTextLabel.text = @"在线";
            break;
            
        case 1:
            cell.detailTextLabel.text = @"离开";
            break;
            
        case 2:
            cell.detailTextLabel.text = @"离线";
            break;
            
        default:
            cell.detailTextLabel.text = @"未知";
            break;
    }
    return cell;
}

// 数据库内容改变
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    WCLog(@"");
    [self.tableView reloadData];
}

@end
