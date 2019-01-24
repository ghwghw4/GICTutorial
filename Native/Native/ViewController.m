//
//  ViewController.m
//  Native
//
//  Created by 龚海伟 on 2019/1/22.
//  Copyright © 2019年 龚海伟. All rights reserved.
//

#import "ViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define cellMarginLeft 15
#define cellMarginTop 10
#define headIconSize 40
#define textMarginTop 10
#define ScreenWidth [UIScreen mainScreen].bounds.size.width

#define TextFontSize 14


CGFloat calcuTextHeight(NSString *text){
    CGRect rect = [text boundingRectWithSize:CGSizeMake(ScreenWidth - 2*cellMarginLeft, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:TextFontSize]} context:nil];
    return rect.size.height;
}

CGFloat calcuCellHeight(NSDictionary *dict){
    return cellMarginTop*2 + headIconSize + textMarginTop + calcuTextHeight(dict[@"text"]);
}



@interface CustomTableViewCell:UITableViewCell{
    NSArray *dataArray;
    
    UIImageView *headIconView;
    UILabel *lblName;
    UILabel *lblText;
}
-(void)updateUI:(NSDictionary *)dict;
@end

@implementation CustomTableViewCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    headIconView = [[UIImageView alloc] initWithFrame:CGRectMake(cellMarginLeft, cellMarginTop, headIconSize, headIconSize)];
    headIconView.backgroundColor = [UIColor grayColor];
    headIconView.layer.cornerRadius = headIconSize / 2;
    headIconView.clipsToBounds = YES;
    [self.contentView addSubview:headIconView];
    
    lblName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(headIconView.frame) + 5, cellMarginTop, 200, headIconSize)];
    [self.contentView addSubview:lblName];
    
    lblText = [[UILabel alloc] initWithFrame:CGRectMake(cellMarginLeft, cellMarginTop + headIconSize + textMarginTop, ScreenWidth - 2*cellMarginLeft, 0)];
    lblText.numberOfLines = -1;
    lblText.font = [UIFont systemFontOfSize:TextFontSize];
    [self.contentView addSubview:lblText];
    return self;
}

-(void)updateUI:(NSDictionary *)dict{
    lblName.text = [dict objectForKey:@"name"];
    [headIconView sd_setImageWithURL:[NSURL URLWithString:dict[@"headIcon"]]];
    lblText.text = [dict objectForKey:@"text"];

    CGRect textFrame = lblText.frame;
    textFrame.size.height = calcuTextHeight(lblText.text);
    lblText.frame = textFrame;
}
@end




@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSArray *dataArray;
}

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 加载列表
    {
        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"data.json"]];
        dataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

        // 初始化UITableView
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[CustomTableViewCell class] forCellReuseIdentifier:@"CustomTableViewCell"];
        [self.view addSubview:tableView];
    }
    
//    // 测试动画
//    {
//        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
//        v.center = self.view.center;
//        v.backgroundColor = [UIColor redColor];
//        [self.view addSubview:v];
//
//        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
//        animation.fromValue = @(0);
//        animation.toValue = @(100);
//        animation.autoreverses = YES;
//        animation.repeatCount = HUGE_VAL;
//        animation.duration = 0.3;
//        [v.layer addAnimation:animation forKey:@"translationAnimation"];
//    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return calcuCellHeight([dataArray objectAtIndex:indexPath.row]);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomTableViewCell"];
    [cell updateUI:[dataArray objectAtIndex:indexPath.row]];
    return cell;
}

@end
