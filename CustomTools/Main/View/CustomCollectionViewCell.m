//
//  CustomCollectionViewCell.m
//  CustomTools
//
//  Created by yuyuyu on 2021/2/9.
//  Copyright © 2021 yuyuyu. All rights reserved.
//

#import "CustomCollectionViewCell.h"
#import <Masonry.h>

@implementation CustomCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    [self setupSubviews];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    self.backgroundColor = THEME_COLOR;
//    self.layer.borderColor = [UIColor redColor].CGColor;
//    self.layer.borderWidth = 1.0;
    
    [self addSubview:self.contentLabel];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(8);
        make.right.bottom.mas_equalTo(-8);
    }];
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:13];
        _contentLabel.textColor = [UIColor whiteColor];
        _contentLabel.numberOfLines = 2;
    }
    return _contentLabel;
}

@end
