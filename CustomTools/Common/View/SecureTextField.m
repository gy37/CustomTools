//
//  SecureTextField.m
//  weimuyunpro
//
//  Created by yuyuyu on 2022/3/31.
//  Copyright © 2022 yuyuyu. All rights reserved.
//

#import "SecureTextField.h"

typedef NS_ENUM(NSInteger, SecureKeyboardType) {
    SecureKeyboardTypeCharacter = 0,
    SecureKeyboardTypeSymbol = 1,
    SecureKeyboardTypeNumber = 2,
};

@interface SecureTextField()
@property (nonatomic, assign) CGFloat toolBarHeight;
@property (nonatomic, assign) CGFloat keyWidth;
@property (nonatomic, assign) CGFloat keyHeight;
@property (nonatomic, strong) UIView *customInputView;
@property (nonatomic, strong) UIToolbar *customAccessoryView;
@property (nonatomic, strong) NSArray *numbers;
@property (nonatomic, strong) NSArray *letters;
@property (nonatomic, strong) NSArray *symbols;
@property (nonatomic, strong) NSArray *controls;
@property (nonatomic, assign) SecureKeyboardType secureKeyboardType;
@end

@implementation SecureTextField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        [self initSubViews];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initData];
    [self initSubViews];
}

#pragma mark - 初始化

- (void)initData {
    self.numbers = [@"0 1 2 3 4 5 6 7 8 9" componentsSeparatedByString:@" "];
    self.letters = [@"a b c d e f g h i j k l m n o p q r s backspace uppercase t u v w x y z return" componentsSeparatedByString:@" "];
    self.controls = [@"backspace uppercase return" componentsSeparatedByString:@" "];
    self.symbols = [@"~ ` ! @ # $ % ^ & * ( ) _ - + = { [ } ] | \\ : ; \" ' < , > backspace . ? / € ￡ ¥ space  return" componentsSeparatedByString:@" "];
    [self addTarget:self action:@selector(onBeginEditing) forControlEvents:UIControlEventEditingDidBegin];
    self.secureTextEntry = YES;
}

- (void)initSubViews {
    self.toolBarHeight = 44;
    self.keyWidth = (COMMON_SCREEN_WIDTH - 20 - 8 * 9) / 10;
    self.keyHeight = 42;
    self.secureKeyboardType = SecureKeyboardTypeCharacter;
    self.inputView = self.customInputView;
    self.inputAccessoryView = self.customAccessoryView;
}

- (UIView *)customInputView {
    if (!_customInputView) {
        _customInputView = [self getSecureView];
        _customInputView.frame = CGRectMake(0, 0, COMMON_SCREEN_WIDTH, 4 * (self.keyHeight + 10) + 10);
        NSArray *keys = [self.numbers arrayByAddingObjectsFromArray:self.letters];
        for (int i = 0; i < keys.count; i++) {
            NSString *title = keys[i];
            UIButton *character = [self createKeyButton:title position:CGPointMake(10 + (i % 10) * (self.keyWidth + 8), 10 + (i / 10) * (self.keyHeight + 10)) size:CGSizeMake(self.keyWidth, self.keyHeight)];
            if ([title isEqualToString:@"backspace"]) {
                [character addTarget:self action:@selector(deleteCharacter:) forControlEvents:UIControlEventTouchUpInside];
                [character setTitle:@"" forState:UIControlStateNormal];
                [character setImage:[UIImage imageNamed:@"backspace"] forState:UIControlStateNormal];
                [character setImage:[UIImage imageNamed:@"backspace_selected"] forState:UIControlStateHighlighted];
                character.backgroundColor = [UIColor lightGrayColor];
            } else if ([title isEqualToString:@"uppercase"]) {
                [self setupUppercaseButton:character isKey:NO];
            } else if ([title isEqualToString:@"return"]) {
                CGRect frame = character.frame;
                frame.size = CGSizeMake(self.keyWidth * 2 + 8, self.keyHeight);
                character.frame = frame;
                character.titleLabel.font = [UIFont systemFontOfSize:18];
                character.backgroundColor = [UIColor lightGrayColor];
                [character addTarget:self action:@selector(returnKeyClicked) forControlEvents:UIControlEventTouchUpInside];
            }
            [_customInputView addSubview:character];
        }
    }
    return _customInputView;
}

- (UIToolbar *)customAccessoryView {
    if (!_customAccessoryView) {
        _customAccessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, COMMON_SCREEN_WIDTH, self.toolBarHeight)];
        UIBarButtonItem *titleItem = [[UIBarButtonItem alloc] initWithTitle:@"安全键盘" style:UIBarButtonItemStylePlain target:self action:NULL];
        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:NULL];
        UIBarButtonItem *typeItem = [[UIBarButtonItem alloc] initWithTitle:@"符号" style:UIBarButtonItemStylePlain target:self action:@selector(changeKeyboardType:reset:)];
        [_customAccessoryView setItems:@[titleItem, spaceItem, typeItem] animated:NO];
    }
    return _customAccessoryView;
}

- (UIButton *)createKeyButton:(NSString *)title position:(CGPoint)position size:(CGSize)size {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectZero;
    frame.origin = position;
    frame.size = size;
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font = [UIFont systemFontOfSize:22];
    button.backgroundColor = [UIColor whiteColor];
    button.layer.cornerRadius = 4;
//            button.layer.masksToBounds = YES;
    button.layer.shadowOpacity = 0.3;
    button.layer.shadowOffset = CGSizeMake(0, 2);
    [button addTarget:self action:@selector(clickKey:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)setupUppercaseButton:(UIButton *)button isKey:(BOOL)isKey {
    if (isKey) {
        [button setImage:nil forState:UIControlStateNormal];
        [button setImage:nil forState:UIControlStateSelected];
        [button addTarget:self action:@selector(clickKey:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor whiteColor];
    } else {
        [button setImage:[UIImage imageNamed:@"arrow_up"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"arrow_up_fill"] forState:UIControlStateSelected];
        [button setTitle:@"" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(uppercaseCharacter:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor lightGrayColor];
    }
}

- (void)setupSpaceButton:(UIButton *)button isBig:(BOOL)isBig {
    CGRect frame = button.frame;
    if (isBig) {
        frame.size = CGSizeMake(self.keyWidth * 2 + 8, self.keyHeight);
        button.frame = frame;
        button.titleLabel.font = [UIFont systemFontOfSize:18];
        button.backgroundColor = [UIColor whiteColor];
    } else {
        frame.size = CGSizeMake(self.keyWidth, self.keyHeight);
        button.frame = frame;
        button.titleLabel.font = [UIFont systemFontOfSize:22];
        button.backgroundColor = [UIColor whiteColor];
    }
}

#pragma mark - 键盘点击事件

- (void)clickKey:(UIButton *)button {
    if ([self.controls containsObject:button.titleLabel.text] || button.titleLabel.text.length==0) {
        return;
    }
    NSString *inputKey = button.titleLabel.text;
    if ([button.titleLabel.text isEqualToString:@"space"]) {
        inputKey = @" ";
    }
    self.text = [NSString stringWithFormat:@"%@%@", self.text, inputKey];
    [self sendActionsForControlEvents:UIControlEventEditingChanged];//直接设置text不会触发controlevent事件，需要调用此方法
}

- (void)deleteCharacter:(UIButton *)button {
    self.text = self.text.length ? [self.text substringToIndex:self.text.length - 1] : @"";
    [self sendActionsForControlEvents:UIControlEventEditingChanged];//直接设置text不会触发controlevent事件，需要调用此方法
}

- (void)uppercaseCharacter:(UIButton *)button {
    button.selected = !button.selected;
    for (UIButton *keyButton in self.customInputView.subviews) {
        if ([self.controls containsObject:keyButton.titleLabel.text]) {
            continue;
        }
        NSString *title = button.isSelected ? [keyButton.titleLabel.text uppercaseString] : [keyButton.titleLabel.text lowercaseString];
        [keyButton setTitle:title forState:UIControlStateNormal];
    }
}

- (void)returnKeyClicked {
    [self resignFirstResponder];
}

#pragma mark - 键盘类型
//更改键盘类型
- (void)changeKeyboardType:(UIBarButtonItem *)item reset:(BOOL)isReset {
    self.secureKeyboardType = !isReset && self.secureKeyboardType == SecureKeyboardTypeCharacter ? SecureKeyboardTypeSymbol : SecureKeyboardTypeCharacter;
    BOOL isSymbol = self.secureKeyboardType == SecureKeyboardTypeSymbol;
    NSArray *keys = isSymbol ? self.symbols : [self.numbers arrayByAddingObjectsFromArray:self.letters];
    for (int i = 0; i < self.customInputView.subviews.count; i ++) {
        NSString *key = (keys.count - 1 < i) || [keys[i] isEqualToString:@"backspace"] || [keys[i] isEqualToString:@"uppercase"] ? @"" : keys[i];
        UIButton *keyButton = self.customInputView.subviews[i];
        if (i == 30) {
            [self setupUppercaseButton:keyButton isKey:isSymbol];
            [keyButton setTitle:isSymbol?key:@"" forState:UIControlStateNormal|UIControlStateSelected];
        } else if (i == 36) {
            [self setupSpaceButton:keyButton isBig:isSymbol];
        } else if (i == 37) {
            CGRect frame = keyButton.frame;
            frame.size = isSymbol ? CGSizeMake(0, 0) : CGSizeMake(self.keyWidth, self.keyHeight);
            keyButton.frame = frame;
        }
        [keyButton setTitle:key forState:UIControlStateNormal];
    }
    item.title = isSymbol ? @"数字/字母" : @"符号";
}

- (NSArray *)shuffleArray:(NSArray *)items {
    NSMutableArray *newItems = [NSMutableArray arrayWithArray:items];
    for (int i = 0; i < newItems.count; i++) {
        int randomIndex = arc4random()%(newItems.count - i) + i;
        id item = newItems[randomIndex];
        if ([self.controls containsObject:item] || [self.controls containsObject:newItems[i]]) continue;
        newItems[randomIndex] = newItems[i];
        newItems[i] = item;
    }
    return newItems;
}

- (void)onBeginEditing {
    self.numbers = [self shuffleArray:self.numbers];
    self.letters = [self shuffleArray:self.letters];
//    self.symbols = [self shuffleArray:self.symbols];
    [self changeKeyboardType:self.customAccessoryView.items[2] reset:YES];
}


#pragma mark - 防截屏，通过UITextfield的安全输入实现
- (UIView *)getSecureView{
    UITextField *bgTextField = [[UITextField alloc] init];
    [bgTextField setSecureTextEntry:YES];
    
    UIView *bgView = bgTextField.subviews.firstObject;
    [bgView setUserInteractionEnabled:YES];
    return bgView;
}

@end
