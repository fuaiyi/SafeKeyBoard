//
//  SafeKeyboard.m
//  demo
//
//  Created by gaofu on 2017/3/27.
//  Copyright © 2017年 siruijk. All rights reserved.
//
//  Abstract:安全键盘

#import "SafeKeyboard.h"
#import <Masonry/Masonry.h>

static NSString * const observeValueForKeyPath = @"safeKeyboardText";

const static BOOL randomKeyboard = YES;//是否使用随机键盘
const static BOOL changeWhenAppear = YES;//每次键盘出现都改变随机(随机键盘才有效)

#define kKeyBoardHeight (0.45 * [UIScreen mainScreen].bounds.size.height)//整个键盘的高度
#define KToolBarViewHeight 44.0f //工具条的高度
#define kItemWidth ([UIScreen mainScreen].bounds.size.width - 2 * self.itemSpace) / 3 //按钮的宽度
#define kItemHeight (self.frame.size.height - 3 * self.itemSpace - KToolBarViewHeight) / 4 //按钮的高度


@interface SafeKeyboard ()<UICollectionViewDelegate,UICollectionViewDataSource>

@end


@implementation SafeKeyboard
{
    //记录下部的键盘
    UICollectionView *_keyboardView;
    //键盘的数据源
    NSMutableArray *_titleArr;
    //记录按钮服务的对象
    UITextField *_textField;
    
    
    SKSafeKeyboardDidChangedBlock _safeKeyboardDidChangedBlock;
}

#pragma mark -
#pragma mark  Public Method

-(void)safeKeyBoardDidChanged:(SKSafeKeyboardDidChangedBlock)safeKeyboardDidChangedBlock
{
    _safeKeyboardDidChangedBlock = safeKeyboardDidChangedBlock;
}

+ (instancetype)keyboardWithTextField:(UITextField *)textField
{
    return [[self alloc] initWithTextField:textField];
}


#pragma mark -
#pragma mark  DataInitialize

-(void)setupDefault
{
    self.itemSpace = 1.0f;
    self.fontColor = [UIColor blackColor];
    self.fontSize = 18.0f;
}

- (void)refresh
{
    if (randomKeyboard)
    {
        [_titleArr removeAllObjects];
        NSMutableArray *startArray=[[NSMutableArray alloc] initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",nil];
        NSMutableArray *resultArray = [[NSMutableArray alloc] initWithCapacity:0];
        NSInteger m = 10;
        for (int i=0; i<m; i++)
        {
            int t=arc4random()%startArray.count;
            resultArray[i] = startArray[t];
            startArray[t] = [startArray lastObject];
            [startArray removeLastObject];
        }
        [resultArray insertObject:@"C" atIndex:9];
        [resultArray insertObject:@"D" atIndex:11];
        _titleArr = resultArray;
    }
    else
    {
        _titleArr = [NSMutableArray arrayWithArray:@[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"C",@"0",@"D"]];
    }
    
    [_keyboardView reloadData];
}


#pragma mark -
#pragma mark  Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self refresh];
        
        [self setupDefault];
        
        [self setupComponents];
    }
    return self;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:observeValueForKeyPath])
    {
        _safeKeyboardDidChangedBlock ? _safeKeyboardDidChangedBlock(change[NSKeyValueChangeNewKey]) : nil;
    }
}


#pragma mark -
#pragma mark  Interface Components

- (void)setupComponents
{
    
    self.bounds = CGRectMake(0, 0, self.bounds.size.width, kKeyBoardHeight);
    
    [self setupToolBar];
    [self setupCollectionView];
    
}

-(void)setupToolBar
{
    UIToolbar *toolBar = [UIToolbar new];
    toolBar.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self addSubview:toolBar];
    
    
    UIImageView *safeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"keyboard_safe"]];
    [toolBar addSubview:safeImage];
    
    UILabel *safeLabel = [UILabel new];
    safeLabel.textAlignment = NSTextAlignmentCenter;
    safeLabel.text = @"安全键盘";
    safeLabel.textColor = self.fontColor;
    safeLabel.font = [UIFont systemFontOfSize:15];
    [toolBar addSubview:safeLabel];
    
    
    UIBarButtonItem *flexibleBarBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *finishInputBarBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBtnClick)];
    toolBar.tintColor = [UIColor blackColor];
    toolBar.items = @[flexibleBarBtnItem, finishInputBarBtnItem];
    
    
    [toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
        make.height.mas_equalTo(KToolBarViewHeight);
    }];
    
    [safeImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(15.0f, 17.0f));
        make.centerY.equalTo(toolBar);
        make.trailing.equalTo(safeLabel.mas_leading).offset(-6.0f);
    }];
    
    [safeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(CGSizeMake(toolBar.center.x+11.0f, toolBar.center.y));
    }];
    
    
    
}

-(void)setupCollectionView
{
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumInteritemSpacing = self.itemSpace;
    flowLayout.minimumLineSpacing = self.itemSpace;
    flowLayout.sectionInset = UIEdgeInsetsMake(self.itemSpace, 0, -self.itemSpace, 0);
    flowLayout.itemSize = CGSizeMake(kItemWidth, kItemHeight);
    
    _keyboardView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, KToolBarViewHeight, [UIScreen mainScreen].bounds.size.width, self.frame.size.height - KToolBarViewHeight) collectionViewLayout:flowLayout];
    
    _keyboardView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _keyboardView.delaysContentTouches = NO;
    _keyboardView.dataSource = self;
    _keyboardView.delegate = self;
    [self addSubview:_keyboardView];
    
    [_keyboardView registerClass:[SafeKeyboardImageCell class] forCellWithReuseIdentifier:NSStringFromClass([SafeKeyboardImageCell class])];
    [_keyboardView registerClass:[SafeKeyboardTextCell class] forCellWithReuseIdentifier:NSStringFromClass([SafeKeyboardTextCell class])];
    
}


#pragma mark -
#pragma mark  Target Action Methods

//完成按钮点击
- (void)doneBtnClick
{
    if (_textField.superview)
    {
        [_textField.superview endEditing:YES];
    }
    else
    {
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    }
}


-(void)textFieldBeginEditing
{
    if (randomKeyboard && changeWhenAppear)
    {
        [self refresh];
    }
    //如果用到了IQKeyboardManager
    //    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}
//
-(void)textFieldEndEditing
{
    //如果用到了IQKeyboardManager
    //    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
}


#pragma mark -
#pragma mark  Private Methods

//自定义私有的init方法
- (instancetype)initWithTextField:(UITextField *)textField
{
    self = [super init];
    if (self)
    {
        _textField = textField;
        _textField.inputView = self;
        [_textField addObserver:self forKeyPath:observeValueForKeyPath options:NSKeyValueObservingOptionNew context:nil];
        [_textField addTarget:self action:@selector(textFieldBeginEditing) forControlEvents:UIControlEventEditingDidBegin];
        //        [_textField addTarget:self action:@selector(textFieldEndEditing) forControlEvents:UIControlEventEditingDidEnd];
    }
    return self;
}


- (void)showInputWithNumberStr:(NSString *)numStr
{
    
    if ([@"C" isEqualToString:numStr])
    {
        _textField.text = nil;
    }
    else if([@"D" isEqualToString:numStr])
    {
        [_textField deleteBackward];
    }
    else
    {
        [_textField insertText:numStr];
    }
}


#pragma mark -
#pragma mark  Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _titleArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.item == 11)
    {
        SafeKeyboardImageCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SafeKeyboardImageCell class]) forIndexPath:indexPath];
        cell.cellImageView.image = [UIImage imageNamed:@"keyboard_delete"];
        return cell;
    }
    else
    {
        SafeKeyboardTextCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SafeKeyboardTextCell class]) forIndexPath:indexPath];
        cell.cellTextLabel.textColor = self.fontColor;
        cell.cellTextLabel.text = _titleArr[indexPath.item];
        return cell;
    }
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self showInputWithNumberStr:_titleArr[indexPath.row]];
}

-  (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [cell.contentView setBackgroundColor:[UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1.0]];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
}


#pragma mark -
#pragma mark  Dealloc

- (void)dealloc
{
    //移除观察
    [_textField removeObserver:self forKeyPath:observeValueForKeyPath];
}


@end






@interface SafeKeyboardImageCell ()

@end


@implementation SafeKeyboardImageCell

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        
        [self setupCell];
        
    }
    return self;
}

-(void)setupCell
{
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.cellImageView = [[UIImageView alloc] init];
    self.cellImageView.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:self.cellImageView];
    
    
    [self.cellImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.contentView);
        make.leading.equalTo(self.contentView);
        make.top.equalTo(self.contentView);
    }];
    
}

@end



@interface SafeKeyboardTextCell ()

@end


@implementation SafeKeyboardTextCell

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        
        [self setupCell];
        
    }
    return self;
}

-(void)setupCell
{
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.cellTextLabel = [[UILabel alloc] init];
    self.cellTextLabel .textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.cellTextLabel ];
    
    [self.cellTextLabel  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.contentView);
        make.leading.equalTo(self.contentView);
        make.top.equalTo(self.contentView);
    }];
}

@end
