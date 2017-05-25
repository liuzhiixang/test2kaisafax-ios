//
//  JXCommandView.m
//

#import "JXCommandView.h"
#import "JXMcsEvaluation.h"

#define SelfFrameSizeWidth self.frame.size.width
#define SelfFrameSizeHeight self.frame.size.height
#define subViewSpace 20
#define RatingSizeWidth 35 * 5 + 4 * 5
#define RatingSizeHeight 30
#define ToolBarHeight 44
#define WindowColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1]
#define BackgroudColor [UIColor colorWithWhite:0.95 alpha:1]


@interface JXCommandView ()<UIPickerViewDataSource, UIPickerViewDelegate, JXRatingViewDelegate>

@property(nonatomic, strong) UIView *contentView;
@property(nonatomic, strong) UIToolbar *toolBar;
@property(nonatomic, weak) JXRatingView *ratingView;
@property(nonatomic, weak) UILabel *infoLabel;

@property(nonatomic, assign) JXMcsEvaluation *model;
@property(nonatomic, strong) NSArray *questions;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, assign) NSInteger currentRow;
@property(nonatomic,strong) UIView *coverView;

@property(nonatomic, strong) NSArray *datasource;

@end

@implementation JXCommandView

- (instancetype)initWithTtile:(NSString *)title
                     delegate:(id<JXCommandViewDelegate>)delegate
                        model:(id)model {
    if (self = [super init]) {
        //初始化背景视图，添加手势
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,
                                [UIScreen mainScreen].bounds.size.height);
        self.title = title;
        if ([model isKindOfClass:[JXMcsEvaluation class]]) {
            if (self.questions) {
                self.questions = nil;
            }
            self.model = model;
        } else if ([model isKindOfClass:[NSArray class]]) {
            if (self.model) {
                self.model = nil;
            }
            self.questions = model;
        }
        self.backgroundColor = WindowColor;
        self.userInteractionEnabled = YES;
        [self setupSubviews];
        if (delegate) {
            self.delegate = delegate;
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([self.contentView isKindOfClass:[UIPickerView class]]) {
        self.contentView.origin = CGPointMake(0, SelfFrameSizeHeight - self.contentView.height);
    } else {
        self.contentView.frame =
                CGRectMake(0, SelfFrameSizeHeight * 0.5 + 2 * ToolBarHeight, SelfFrameSizeWidth,
                           SelfFrameSizeHeight * 0.5 - 2 * ToolBarHeight);
        self.ratingView.frame =
                CGRectMake(((CGRectGetWidth(self.contentView.frame) - RatingSizeWidth) / 2),
                           subViewSpace, RatingSizeWidth, RatingSizeHeight);
        self.infoLabel.frame =
                CGRectMake(subViewSpace, CGRectGetMaxY(self.ratingView.frame) + subViewSpace,
                           (CGRectGetWidth(self.contentView.frame) - 2 * subViewSpace),
                           (CGRectGetHeight(self.contentView.frame) -
                            CGRectGetMaxY(self.ratingView.frame) - subViewSpace));
    }

    self.toolBar.frame = CGRectMake(
            0, SelfFrameSizeHeight - CGRectGetHeight(self.contentView.frame) - ToolBarHeight,
            SelfFrameSizeWidth, ToolBarHeight);

    self.coverView.frame = CGRectMake(0, 0, SelfFrameSizeWidth,
                                      SelfFrameSizeHeight - CGRectGetMaxY(self.toolBar.frame));
}

#pragma mark - public

- (void)showInView:(UIView *)view {
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self];
    self.contentView.origin = CGPointMake(0, SelfFrameSizeHeight + ToolBarHeight);
    self.toolBar.origin = CGPointMake(0, SelfFrameSizeHeight);
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self layoutSubviews];
                     }];
}

- (void)hideView {
    [self tappedCancel];
}

#pragma mark - private

- (void)setupSubviews {
    [self addSubview:self.toolBar];
    [self addSubview:self.contentView];
    [self addSubview:self.coverView];
}

- (void)tappedCancel {
    [UIView animateWithDuration:0.25
            animations:^{
                self.toolBar.origin = CGPointMake(0, [UIScreen mainScreen].bounds.size.height);
                self.contentView.origin =
                        CGPointMake(0, [UIScreen mainScreen].bounds.size.height + 44);
            }
            completion:^(BOOL finished) {
                if (finished) {
                    [self removeFromSuperview];
                }
            }];
}

- (void)clickConfirmItem {
    NSInteger row;
    if ([self.contentView isKindOfClass:[UIPickerView class]]) {
        row = [(UIPickerView *)self.contentView selectedRowInComponent:0];
    } else {
        row = self.currentRow;
    }
    if (self.model) {
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(didfinishedCommandWithScore:)]) {
            if (_ratingView && !self.ratingView.rating) {
                [sJXHUD showMessage:@"请先选择一个评价" duration:1.f];
                return;
            }
            [self.delegate didfinishedCommandWithScore:[self changeToScoreWithIndex:row]];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedQuestion:)]) {
            [self.delegate didSelectedQuestion:self.datasource[row]];
        }
    }
}

- (int)changeToScoreWithIndex:(NSInteger)index {
    int score = 0;
    switch (index) {
        case 0:
            score = 5;
            break;
        case 1:
            score = 4;
            break;
        case 2:
            score = 3;
            break;
        case 3:
            score = 2;
            break;
        case 4:
            score = 1;
            break;
        default:
            break;
    }
    return score;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.datasource.count;
}

//- (NSString *)pickerView:(UIPickerView *)pickerView
//             titleForRow:(NSInteger)row
//            forComponent:(NSInteger)component {
//    id item = self.datasource[row];
//    if ([item isKindOfClass:[JXMcsEvaluationItem class]]) {
//        JXMcsEvaluationItem *model = item;
//        return model.text;
//    } else {
//        return item;
//    }
//}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view {
    NSString *showText;
    id item = self.datasource[row];
    if ([item isKindOfClass:[JXMcsEvaluationItem class]]) {
        JXMcsEvaluationItem *model = item;
        showText = model.text;
    } else {
        showText = item;
    }
    CGSize size =
            [showText boundingRectWithSize:CGSizeMake(
                                                   [pickerView rowSizeForComponent:component].width,
                                                   CGFLOAT_MAX)
                                   options:NSStringDrawingUsesLineFragmentOrigin |
                                           NSStringDrawingUsesFontLeading
                                attributes:@{
                                    NSFontAttributeName : [UIFont systemFontOfSize:20]
                                }
                                   context:nil]
                    .size;
    CGFloat height = size.height > [pickerView rowSizeForComponent:component].height
                             ? size.height + 10
                             : [pickerView rowSizeForComponent:component].height;
    UILabel *label = [[UILabel alloc]
            initWithFrame:CGRectMake(0, 0, [pickerView rowSizeForComponent:component].width,
                                     height)];
    label.numberOfLines = 0;
    label.text = showText;
    label.font = [UIFont systemFontOfSize:20];
    label.backgroundColor = [UIColor clearColor];
    [label setTextAlignment:NSTextAlignmentCenter];
    return label;
}

#pragma mark - UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 60;
}

#pragma mark JXRatingViewDelegate

/**
 *  评分改变
 *
 *  @param newRating 新的值
 */
- (void)ratingChanged:(float)newRating {
    self.currentRow = 5 - (int)newRating;
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(didfinishedCommandWithScore:)]) {
        [self.delegate didfinishedCommandWithScore:(int)newRating];
    }
}

#pragma mark - getter

- (UIView *)contentView {
    if (!_contentView) {
        if (!self.model || self.model.type != JXSatisficationTypeStar) {
            CGFloat width = [UIScreen mainScreen].bounds.size.width;
            _contentView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, width, 216)];
            UIPickerView *pickview = (UIPickerView *)_contentView;
            pickview.dataSource = self;
            pickview.delegate = self;
            pickview.backgroundColor = BackgroudColor;
            pickview.showsSelectionIndicator = YES;
            pickview.layer.borderWidth = 0.5;
            pickview.layer.borderColor = [UIColor darkGrayColor].CGColor;
        } else {
            // ratingView
            JXRatingView *ratingView = [[JXRatingView alloc] init];
            ratingView.isIndicator = NO;    //指示器，就不能滑动了，只显示评分结果
            [ratingView setImageDeselected:@"evaluate"
                              halfSelected:nil
                              fullSelected:@"evaluate_selected"
                               andDelegate:self];

            // infoLabel
            UILabel *infoLabel = [[UILabel alloc] init];
            infoLabel.numberOfLines = 0;
            infoLabel.text = @"\t\t5颗❤️:表示非常满意\n\t\t4颗❤️:"
                             @"表示满意\n\t\t3颗❤️:"
                             @"表示一般\n\t\t2颗❤️:表示不满意\n\t\t1颗❤️:"
                             @"表示非常不满意";
            infoLabel.font = [UIFont systemFontOfSize:15.f];
            infoLabel.textColor = [UIColor grayColor];

            self.ratingView = ratingView;
            self.infoLabel = infoLabel;

            // contentView
            _contentView = [[UIView alloc] init];
            _contentView.backgroundColor = [UIColor whiteColor];
            _contentView.userInteractionEnabled = YES;
            [_contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:nil
                                                                                       action:nil]];
            [_contentView addSubview:ratingView];
            [_contentView addSubview:infoLabel];
        }
    }
    return _contentView;
}

- (UIToolbar *)toolBar {
    if (!_toolBar) {
        _toolBar = [[UIToolbar alloc] init];
        _toolBar.translatesAutoresizingMaskIntoConstraints = NO;
        _toolBar.barTintColor = BackgroudColor;
        _toolBar.backgroundColor = [UIColor clearColor];
        UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(tappedCancel)];
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]
                initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                     target:nil
                                     action:nil];
        UIBarButtonItem *item2 =
                [[UIBarButtonItem alloc] initWithTitle:@"确定"
                                                 style:UIBarButtonItemStyleDone
                                                target:self
                                                action:@selector(clickConfirmItem)];
        UIBarButtonItem *titleItem = [[UIBarButtonItem alloc] initWithTitle:self.title
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:nil
                                                                     action:nil];
        titleItem.tintColor = [UIColor blackColor];
        _toolBar.items = @[ item1, flexibleSpace, titleItem, flexibleSpace, item2 ];
    }
    return _toolBar;
}

- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [[UIView alloc] init];
        [_coverView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                    initWithTarget:self
                                    action:@selector(hideView)]];
    }
    return _coverView;
}

- (NSArray *)datasource {
    if (self.model) {
        if ((self.model.type == JXSatisficationTypeSingleSelection) ||
            (self.model.type == JXSatisficationTypeScore ||
             (self.model.type == JXSatisficationTypeCustom))) {
            _datasource = [[self.model.itemList reverseObjectEnumerator] allObjects];
            ;
        }
    } else {
        _datasource = self.questions;
    }
    return _datasource;
}

@end

@implementation JXRatingView

/**
 *  初始化设置未选中图片、半选中图片、全选中图片，以及评分值改变的代理（可以用
 *  Block）实现
 *
 *  @param deselectedName   未选中图片名称
 *  @param halfSelectedName 半选中图片名称
 *  @param fullSelectedName 全选中图片名称
 *  @param delegate          代理
 */
- (void)setImageDeselected:(NSString *)deselectedName
              halfSelected:(NSString *)halfSelectedName
              fullSelected:(NSString *)fullSelectedName
               andDelegate:(id<JXRatingViewDelegate>)delegate {
    self.delegate = delegate;

    unSelectedImage = JXChatImage(deselectedName);
    halfSelectedImage = halfSelectedName == nil ? unSelectedImage : JXChatImage(halfSelectedName);
    fullSelectedImage = JXChatImage(fullSelectedName);

    height = 0.0, width = 0.0;

    space = 5.f;

    if (height < [fullSelectedImage size].height) {
        height = [fullSelectedImage size].height;
    }
    if (height < [halfSelectedImage size].height) {
        height = [halfSelectedImage size].height;
    }
    if (height < [unSelectedImage size].height) {
        height = [unSelectedImage size].height;
    }
    if (width < [fullSelectedImage size].width) {
        width = [fullSelectedImage size].width;
    }
    if (width < [halfSelectedImage size].width) {
        width = [halfSelectedImage size].width;
    }
    if (width < [unSelectedImage size].width) {
        width = [unSelectedImage size].width;
    }

    starRating = 0.0;
    lastRating = 0.0;

    _s1 = [[UIImageView alloc] initWithImage:unSelectedImage];
    _s2 = [[UIImageView alloc] initWithImage:unSelectedImage];
    _s3 = [[UIImageView alloc] initWithImage:unSelectedImage];
    _s4 = [[UIImageView alloc] initWithImage:unSelectedImage];
    _s5 = [[UIImageView alloc] initWithImage:unSelectedImage];

    [_s1 setFrame:CGRectMake(0, 0, width, height)];
    [_s2 setFrame:CGRectMake(width + space, 0, width, height)];
    [_s3 setFrame:CGRectMake(2 * (width + space), 0, width, height)];
    [_s4 setFrame:CGRectMake(3 * (width + space), 0, width, height)];
    [_s5 setFrame:CGRectMake(4 * (width + space), 0, width, height)];

    [_s1 setUserInteractionEnabled:NO];
    [_s2 setUserInteractionEnabled:NO];
    [_s3 setUserInteractionEnabled:NO];
    [_s4 setUserInteractionEnabled:NO];
    [_s5 setUserInteractionEnabled:NO];

    [self addSubview:_s1];
    [self addSubview:_s2];
    [self addSubview:_s3];
    [self addSubview:_s4];
    [self addSubview:_s5];

    CGRect frame = [self frame];
    frame.size.width = width * 5 + 4 * space;
    frame.size.height = height;
    [self setFrame:frame];
}

/**
 *  设置评分值
 *
 *  @param rating 评分值
 */
- (void)displayRating:(float)rating {
    [_s1 setImage:unSelectedImage];
    [_s2 setImage:unSelectedImage];
    [_s3 setImage:unSelectedImage];
    [_s4 setImage:unSelectedImage];
    [_s5 setImage:unSelectedImage];

    if (rating >= 0.5) {
        [_s1 setImage:halfSelectedImage];
    }
    if (rating >= 1) {
        [_s1 setImage:fullSelectedImage];
    }
    if (rating >= 1.5) {
        [_s2 setImage:halfSelectedImage];
    }
    if (rating >= 2) {
        [_s2 setImage:fullSelectedImage];
    }
    if (rating >= 2.5) {
        [_s3 setImage:halfSelectedImage];
    }
    if (rating >= 3) {
        [_s3 setImage:fullSelectedImage];
    }
    if (rating >= 3.5) {
        [_s4 setImage:halfSelectedImage];
    }
    if (rating >= 4) {
        [_s4 setImage:fullSelectedImage];
    }
    if (rating >= 4.5) {
        [_s5 setImage:halfSelectedImage];
    }
    if (rating >= 5) {
        [_s5 setImage:fullSelectedImage];
    }

    starRating = rating;
    lastRating = rating;
}

/**
 *  获取当前的评分值
 *
 *  @return 评分值
 */
- (float)rating {
    return starRating;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];

    CGPoint point = [[touches anyObject] locationInView:self];
    int newRating = (int)(point.x / (width + space)) + 1;
    if (newRating > 5) return;

    if (point.x < 0) {
        newRating = 0;
    }

    if (newRating != lastRating) {
        [self displayRating:newRating];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [_delegate ratingChanged:lastRating];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.isIndicator) {
        return;
    }

    CGPoint point = [[touches anyObject] locationInView:self];
    int newRating = (int)(point.x / width) + 1;
    if (newRating > 5) return;

    if (point.x < 0) {
        newRating = 0;
    }

    if (newRating != lastRating) {
        [self displayRating:newRating];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

@end
