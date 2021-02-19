//
//  CustomCollectionReusableView.m
//  CustomTools
//
//  Created by yuyuyu on 2021/2/9.
//  Copyright © 2021 yuyuyu. All rights reserved.
//

#import "CustomCollectionReusableView.h"
#import <Masonry.h>

@implementation CustomCollectionReusableView

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
    self.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.7];
    
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
        _contentLabel.textColor = [UIColor blackColor];
        _contentLabel.numberOfLines = 1;
    }
    return _contentLabel;
}

@end
