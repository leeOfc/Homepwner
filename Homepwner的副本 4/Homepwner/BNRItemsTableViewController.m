//
//  BNRItemsTableViewController.m
//  Homepwner
//
//  Created by leo on 2016/12/18.
//  Copyright © 2016年 leo. All rights reserved.
//

#import "BNRItemsTableViewController.h"
#import "BNRItemStore.h"
#import "BNRItem.h"

@interface BNRItemsTableViewController ()

@property (nonatomic, strong) IBOutlet UIView *headView;

@end

@implementation BNRItemsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:@"UITableViewCell"];
    //延迟加载模式 加载headview
    UIView *header = self.headView;
    [self.tableView setTableHeaderView:header];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (instancetype)init
{
    //调用父类制定的初始化方法
    self = [super initWithStyle:UITableViewStylePlain];
    //实现数据源方法，随机创建5个item
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Homepwner";
        
        //创建新的UIBarButtomItem对象
        //将其目标对象设置为当前对象，将其动作方法设置为addNewItem；
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                            target:self
                                                                            action:@selector(addNewItem:)];
        //为UINavgatioinItem对象的rightBarButtpnItem属性赋值，
        //指向新创建的UIBarButtonItem对象；
        navItem.rightBarButtonItem = bbi;
        navItem.leftBarButtonItem = self.editButtonItem;
        
    }
    
    return self;
    }
    

-(instancetype)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)addNewItem:(id)sender{
    //创建NSIndexPath对象，代表的位置是：第一个表格段，最后一个表格行
    //NSInteger lastRow = [self.tableView numberOfRowsInSection:0];
    //新建BNRItem对象并将其加入BNRItemStore对象
    BNRItem *newItem = [[BNRItemStore sharedStore] createItem];
    //获取新创建的对象在allItems数组中的索引
    NSInteger lastRow = [[[BNRItemStore sharedStore] allItems] indexOfObject:newItem];
    
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:lastRow inSection:0];
    //将新行插入UITableView对象
    [self.tableView insertRowsAtIndexPaths:@[indexpath]
                          withRowAnimation:UITableViewRowAnimationTop];
}


#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//   return 1;
//}

//返回行数代码
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return [[[BNRItemStore sharedStore] allItems] count] + 1;
}

//显示详细信息
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //创建uitableViewcell对象，风格使用默认的UITableViewCellDefault
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    if (indexPath.row == [[[BNRItemStore sharedStore]allItems]count]) {
        // Add at the end no more items
        cell.textLabel.text = @"No more items...";
        return cell;
    }
    
    //获取allItems的第n个BNRItem对象
    //然后将该对象的秒速信息富裕给Cell对象的textLable
    NSArray *items = [[BNRItemStore sharedStore] allItems];
    BNRItem *item = items[indexPath.row];
    cell.textLabel.text = [item description];
    
    return cell;
}


- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //如果UITableView对象请求确认的是删除操作......
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *items = [[BNRItemStore sharedStore] allItems];
        BNRItem *item = items[indexPath.row];
        [[BNRItemStore sharedStore] removeItem:item];
        //还要删除表格试图中的相应表格行（带动画效果）
        [tableView deleteRowsAtIndexPaths:@[indexPath]
                 withRowAnimation:UITableViewRowAnimationFade];
    }
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Remove";
}


// Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 NSInteger row = indexPath.row;
 NSInteger lastRow = [[[BNRItemStore sharedStore]allItems]count] +1;
     if (row == lastRow - 1) {
            return NO;
        } else {
            return YES;
        }
 }



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (destinationIndexPath.row == [[[BNRItemStore sharedStore]allItems]count]) {
        return;
    } else{
        [[BNRItemStore sharedStore] moveItemAtIndex:sourceIndexPath.row
                                            toIndex:destinationIndexPath.row];
    }
    
}


- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if( sourceIndexPath.section != proposedDestinationIndexPath.section )
    {
        return sourceIndexPath;
    }
    else
    {
        if (proposedDestinationIndexPath.row == [[[BNRItemStore sharedStore]allItems]count]) {
            return sourceIndexPath;
        } else {
            return proposedDestinationIndexPath;
        }
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BNRDetailViewController *detailViewController = [[BNRDetailViewController alloc] init];
    
    NSArray *items = [[BNRItemStore sharedStore] allItems];
    BNRItem *selectionItem = items[indexPath.row];
    //将选中的BNRItem对象赋给DetailViewController对象
    detailViewController.item = selectionItem;
    
    //  将新创建的BNRDetailViewController对象压入UINavigationController对象的栈
    [self.navigationController pushViewController:detailViewController
                                         animated:YES];
}


@end
