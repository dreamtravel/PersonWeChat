//
//  WCProfileController.m
//  WeChat
//
//  Created by Mac on 15/11/6.
//  Copyright © 2015年 Macmini. All rights reserved.
//

#import "WCProfileController.h"
#import "XMPPvCardTemp.h"

@interface WCProfileController () <UIAlertViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView; //头像
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel; //昵称
@property (weak, nonatomic) IBOutlet UILabel *wechatNumberLabel; //微信号

@property (weak, nonatomic) IBOutlet UILabel *orgUintLabel; //公司
@property (weak, nonatomic) IBOutlet UILabel *departmentLabel; //部门
@property (weak, nonatomic) IBOutlet UILabel *titleLabel; //职位
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel; //电话
@property (weak, nonatomic) IBOutlet UILabel *emailLabel; //邮箱

@property (nonatomic, strong) NSIndexPath *currentPath;
- (IBAction)returnNavigation:(UIBarButtonItem *)sender;
@end

@implementation WCProfileController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置数据
    XMPPvCardTemp *model = [WCXMPPTool sharedWCXMPPTool].vCard.myvCardTemp;
    if (model.photo) {
        self.avatarImageView.image = [UIImage imageWithData:model.photo];
    }
    self.nickNameLabel.text = model.nickname;
    self.wechatNumberLabel.text = [WCAccount shareAccount].account;
    self.orgUintLabel.text = model.orgName;
    if (model.orgUnits.count > 0) {
        self.departmentLabel.text = model.orgUnits.firstObject;
    }
    self.titleLabel.text = model.title;
    self.phoneLabel.text = model.note;
    self.emailLabel.text = model.mailer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveToServer {
    XMPPvCardTemp *model = [WCXMPPTool sharedWCXMPPTool].vCard.myvCardTemp;

    model.photo = UIImageJPEGRepresentation(self.avatarImageView.image, 0.5);
    model.nickname = self.nickNameLabel.text;
    model.orgName = self.orgUintLabel.text;
    model.orgUnits = @[self.departmentLabel.text];
    model.title = self.titleLabel.text;
    model.note = self.phoneLabel.text;
    model.mailer = self.emailLabel.text;
    
    [[WCXMPPTool sharedWCXMPPTool].vCard updateMyvCardTemp:model];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    // 取消选中状态
    [cell setSelected:NO];
    if (indexPath.section == 0 && indexPath.row == 0) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"从相册选择", nil];
        [sheet showInView:self.view];
    } else if (indexPath.section == 0 && indexPath.row == 2) {

    } else {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:cell.textLabel.text message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"保存", nil];
        view.alertViewStyle = UIAlertViewStylePlainTextInput;
        [view textFieldAtIndex:0].text = cell.detailTextLabel.text;
        _currentPath = indexPath;
        [view show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        // 更新数据
        NSString *newText = [alertView textFieldAtIndex:0].text;
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_currentPath];
        cell.detailTextLabel.text = newText;
        [self saveToServer];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // 1、判断照片源是否可用
    /**
     UIImagePickerControllerSourceTypePhotoLibrary     //图片库
     UIImagePickerControllerSourceTypeCamera           //相机
     UIImagePickerControllerSourceTypeSavedPhotosAlbum //相册
     */
    // 2、创建照片选择控制器
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    // 允许编辑图片
    ipc.allowsEditing = YES;
    // 3、设置照片源
    if (buttonIndex == 0) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
            WCLog(@"拍照");
        }
    } else if (buttonIndex == 1) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            WCLog(@"从相册选择");
        }
    }
    // 4、设置代理
    ipc.delegate = self;
    // 5、弹出控制器
    [self presentViewController:ipc animated:YES completion:nil];
}
// 选中照片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    self.avatarImageView.image = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self saveToServer];
}


- (IBAction)returnNavigation:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
