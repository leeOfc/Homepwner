//
//  BNRDetailViewController.m
//  Homepwner
//
//  Created by leo on 2017/2/8.
//  Copyright © 2017年 leo. All rights reserved.
//

#import "BNRDetailViewController.h"
#import "BNRItemStore.h"
#import "BNRImageStore.h"
#import "BNRItem.h"

@interface BNRDetailViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate,
                        UITextFieldDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *imagePickerPopover;

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *serialNumberField;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;

@end

@implementation BNRDetailViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    @throw [NSException exceptionWithName:@"Wrong initializer"
                                   reason:@"Use initForNewItem"
                                 userInfo:nil];
    return nil;
}

- (instancetype) initForNewItem:(BOOL)isNew {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (isNew) {
            UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                      target:self
                                                                                      action:
                                                                      @selector(save:)];
            self.navigationItem.rightBarButtonItem = doneItem;
            UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                        target:self
                                                                                        action:@selector(cancel:)];
            self.navigationItem.leftBarButtonItem = cancelItem;
        }
    }
    return self;
}



- (IBAction)backgroundTapped:(id)sender {
    
    [self.view endEditing:YES];
}

- (void) save:(id) sender {
    
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                     completion:self.dismissBlock];
}

- (void) cancel:(id) sender {
    
    //如果用户按下了cancel按钮，就从BNRItemStore对象移除新建的BNRItem对象
    [[BNRItemStore sharedStore] removeItem:self.item];
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                     completion:self.dismissBlock];
    
}

#pragma mark - takepicture
- (IBAction)takePicture:(id)sender {
    //解决连续两次按camera崩溃
    if ([self.imagePickerPopover isPopoverVisible]) {
        //如果imagePickerPopover指向的是有效的UIPopoverController对象
        //并且该对象的视图是可见的，就关闭这个对象，并将其设置为nil
        [_imagePickerPopover dismissPopoverAnimated:YES];
        _imagePickerPopover = nil;
        return;
}
    
    UIImagePickerController *imagePicker =
    [[UIImagePickerController alloc] init];
    //如果设备支持相机，就使用拍照模式
    //否则让用户从照片库中选择照片
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    //显示UIImagePickerController对象
    //创建UIPopoverController对象前先检查当前设备是不是ipad
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        //创建UIPopoverController对象，用于显示UIImagePickerController对象
        self.imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        self.imagePickerPopover.delegate = self;
        //显示UIpopoverController对象。
        //sender指向的是代表相机按钮的uibarbuttonItem对象
        [self.imagePickerPopover presentPopoverFromBarButtonItem:sender
                                        permittedArrowDirections:UIPopoverArrowDirectionAny
                                                        animated:YES];
    } else {
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    //通过info字典获取选择的照片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    //以itemKey为键，将照屁啊存入BNRImageStore对象
    [[BNRImageStore sharedStore] setImage:image forKey:self.item.itemKey];
    //将照片放入UIImageView对象
    self.imageView.image = image;
    
    //关闭UIImagePickerController对象
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    // 判断UIPopoverController对象是否存在
    if (self.imagePickerPopover) {
        //关闭UIPopoverController对象
        [self.imagePickerPopover dismissPopoverAnimated:YES];
        self.imagePickerPopover = nil;
    } else {
        //关闭以模态形式显示的UIImagePickerController对象
        [self dismissViewControllerAnimated:YES
                                completion:nil];
    }
}

-(void) setItem:(BNRItem *)item
{
    _item = item;
    self.navigationItem.title = _item.itemName;
   }

- (void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    NSLog(@"User dismissed popover");
    self.imagePickerPopover = nil;
}


#pragma mark - view life control

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIInterfaceOrientation io = [[UIApplication sharedApplication] statusBarOrientation];
    [self prepareViewsForOrientaion:io];
    
    BNRItem *item = self.item;
    self.nameField.text = item.itemName;
    self.serialNumberField.text = item.serialNumber;
    self.valueField.text = [NSString stringWithFormat:@"%d", item.valueInDollars];
    //创建NSDAateFormatter对象，用于将NSDate对象转换成简单的日期字符串
    static NSDateFormatter *dateFormatter = nil;
    if (! dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    //将转换后得到的日期字符串设置为dateLabel的标题
    self.dateLabel.text = [dateFormatter stringFromDate:item.dateCreated];
    NSString *itemKey = self.item.itemKey;
    //根据itemKey，从BNRImageStore对象获取照片
    UIImage *imageToDisplay = [[BNRImageStore sharedStore] imageforKey:itemKey];
    //将得到的照片赋给UIImageView对象
    self.imageView.image = imageToDisplay;
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //取消当前的第一响应对象
    [self.view endEditing:YES];
    //将修改保存至BNRItem对象
    
    BNRItem *item = self.item;
    item.itemName = self.nameField.text;
    item.serialNumber = self.serialNumberField.text;
    item.valueInDollars = [self.valueField.text intValue];
    
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void) prepareViewsForOrientaion:(UIInterfaceOrientation) orientation
{
    //如果是ipad， 就不执行任何操作
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return;
    }
    //判断设备是否处于横排
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        self.imageView.hidden = YES;
        self.cameraButton.enabled = NO;
    } else {
        self.imageView.hidden = NO;
        self.cameraButton.enabled = YES;
    }
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self prepareViewsForOrientaion:toInterfaceOrientation];
}

@end
