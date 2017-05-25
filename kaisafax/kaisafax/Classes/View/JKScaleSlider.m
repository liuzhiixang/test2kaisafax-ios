//
//  JKScaleSlider.m
//  HelloWorld
//
//  Created by Jjyo on 16/7/17.
//  Copyright © 2016年 Jjyo. All rights reserved.
//

#import "JKScaleSlider.h"


#define JK_SCALE_SLIDER_CELL        @"SliderCell"


#define DEFAULT_TEXT_SIZE           12
#define DEFAULT_TEXT_COLOR          [UIColor darkGrayColor]

#define DEFAULT_CENTER_LINE_COLOR   [UIColor redColor]

#define DEFAULT_LINE_WIDTH          0.5
#define DEFAULT_LINE_COLOR          [UIColor lightGrayColor]
#define DEFAULT_LINE_SPAN           10
#define DEFAULT_LINE_MAX_HEIGHT     20
#define DEFAULT_LINE_MIN_HEIGHT     10

#pragma mark - Slider Cell

@interface JKScaleSliderCell : UICollectionViewCell
@property (strong, nonatomic) UIImageView *line;
@property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation JKScaleSliderCell

- (id)initWithFrame:(CGRect)frame
{
    self  = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        _line = [UIImageView new];
        [self addSubview:_line];
        
        
        _titleLabel = [UILabel new];
        [self addSubview:_titleLabel];
    }
    return self;
}
@end


#pragma mark - JKScaleSlider

@interface JKScaleSlider() <UICollectionViewDelegate, UICollectionViewDataSource>
{
    BOOL _scrollByDragging;//是否是手动拖动
    NSInteger _realRow;//当前中点所在行
    NSInteger _totalRow;//总行数
    CGPoint _scrollOffset;
}

@property (strong, nonatomic) UICollectionViewFlowLayout *layout;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIImageView *bottomLineView;
@property (strong, nonatomic) UIImageView *centerLineView;

@end


@implementation JKScaleSlider

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self viewInit];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self viewInit];
    }
    return self;
}

/**
 *  加载默认参数
 */
- (void)loadDefaultParam
{
    if (_textSize == 0) {
        _textSize = DEFAULT_TEXT_SIZE;
    }
    if (!_textColor) {
        _textColor = DEFAULT_TEXT_COLOR;
    }
    if (!_centerLineColor) {
        _centerLineColor = DEFAULT_CENTER_LINE_COLOR;
    }
    if (!_lineColor) {
        _lineColor = DEFAULT_LINE_COLOR;
    }
    if (_lineSpan == 0) {
        _lineSpan = DEFAULT_LINE_SPAN;
    }
    if (_lineMaxHeight == 0) {
        _lineMaxHeight = DEFAULT_LINE_MAX_HEIGHT;
    }
    if (_lineMinHeight == 0) {
        _lineMinHeight = DEFAULT_LINE_MIN_HEIGHT;
    }
    if (_stepValue == 0) {
        _stepValue = 1;
    }
}


- (void)viewInit
{
    [self loadDefaultParam];
    
    _layout = [[UICollectionViewFlowLayout alloc]init];
    _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _layout.sectionInset = UIEdgeInsetsZero;
    _layout.minimumLineSpacing = 0.0;
    _layout.minimumInteritemSpacing = 0;
//    _layout.itemSize = CGSizeMake(10, CGRectGetHeight(self.frame));
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:_layout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.showsHorizontalScrollIndicator = false;
    _collectionView.showsVerticalScrollIndicator = false;
    _collectionView.backgroundColor = [UIColor clearColor];
    [self addSubview:_collectionView];

    [_collectionView registerClass:[JKScaleSliderCell class] forCellWithReuseIdentifier:JK_SCALE_SLIDER_CELL];
    
    
    _bottomLineView = [[UIImageView alloc]init];
    _bottomLineView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:_bottomLineView];
    
    
    _centerLineView = [UIImageView new];
    _centerLineView.backgroundColor = [UIColor redColor];
    [self addSubview:_centerLineView];
    
    [self reloadData];
}




- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _collectionView.frame = self.bounds;
    _bottomLineView.frame = CGRectMake(0, CGRectGetMaxY(self.bounds) - 0.5, CGRectGetWidth(self.bounds), 0.5);
    _centerLineView.frame = CGRectMake(CGRectGetMidX(self.bounds) - 0.5, 0, 1, CGRectGetHeight(self.bounds));
    
    CGSize itemSize = CGSizeMake(_lineSpan, CGRectGetHeight(self.bounds) - 1);
    _layout.headerReferenceSize = CGSizeMake(CGRectGetWidth(self.bounds) / 2 - itemSize.width / 2, 0);
    _layout.footerReferenceSize = CGSizeMake(CGRectGetWidth(self.bounds) / 2 - itemSize.width / 2, 0);
    _layout.itemSize = itemSize;
    
}

- (void)setCenterLineColor:(UIColor *)centerLineColor
{
    _centerLineColor = centerLineColor;
    _centerLineView.backgroundColor = centerLineColor;
}

- (void)setLineColor:(UIColor *)lineColor
{
    _lineColor = lineColor;
    _bottomLineView.backgroundColor = lineColor;
}


- (void)reloadData
{
    _totalRow = 0;
    if (_stepValue > 0) {
        _totalRow = ABS((_maxValue - _minValue) / _stepValue + 1);
    }
    if (_totalRow > 0 && _value) {
        [self setValue:_value];
    }
    [_collectionView reloadData];
}


- (NSInteger)valueFromRow:(NSInteger)row
{
    return _minValue + row * _stepValue;
}

- (NSInteger)rowAtValue:(NSInteger)value
{
    return round((value - _minValue) / (_stepValue * 1.));
}


-(void)setRealValueAtRow:(NSInteger)row callback:(BOOL)callback
{
//    if (_realRow == row) {
//        return;
//    }
    _realRow = row;
    NSInteger value = [self valueFromRow:row];
    if (value < _minValue || value > _maxValue) {
        return;
    }
    _value = value;
    if (callback && [_delegate respondsToSelector:@selector(scaleSlider:didChangeValue:)]) {
        [_delegate scaleSlider:self didChangeValue:value];
    }
}

#pragma mark - overwirte

- (void)setValue:(NSInteger)value
{
    [self setValue:value callback:YES];
}


- (void)setValue:(NSInteger)value callback:(BOOL)callback
{
    if (_value != value) {
        
        if (value < _minValue) {
            value = _minValue;
        }
        
        if (value > _maxValue) {
            value = _maxValue;
        }
        
        NSInteger row = [self rowAtValue:value];
        _scrollByDragging = NO;
        [_collectionView setContentOffset:CGPointMake(row * _lineSpan, 0) animated:YES];
        [self setRealValueAtRow:row callback:callback];
    }
}


- (void)setMinValue:(NSInteger)minValue
{
    _minValue = minValue;
    [self reloadData];
}

- (void)setMaxValue:(NSInteger)maxValue
{
    _maxValue = maxValue;
    [self reloadData];
}


#pragma mark - UICollectionView delegate & dataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _totalRow;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"-------- cellForItemAtIndexPath = %@ -------- ", indexPath);
    NSString *title = nil;
    if ([_delegate respondsToSelector:@selector(scaleSlider:titleAtValue:)]) {
        NSInteger value = [self valueFromRow:indexPath.row];
        title = [_delegate scaleSlider:self titleAtValue:value];
    }
    
    JKScaleSliderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:JK_SCALE_SLIDER_CELL forIndexPath:indexPath];
    cell.line.backgroundColor = _lineColor;
    if (title.length > 0) {
        cell.line.frame = CGRectMake(CGRectGetMidX(cell.bounds), CGRectGetHeight(cell.bounds) - _lineMaxHeight, 0.5f, _lineMaxHeight);
        
        cell.titleLabel.hidden = NO;
        cell.titleLabel.font = [UIFont systemFontOfSize:_textSize];
        cell.titleLabel.textColor = _textColor;
        cell.titleLabel.text = title;
        [cell.titleLabel sizeToFit];
        cell.titleLabel.center = CGPointMake(CGRectGetWidth(cell.bounds) / 2 , CGRectGetMinY(cell.line.frame) - CGRectGetHeight(cell.titleLabel.frame) / 2);
        
    }else{
        cell.titleLabel.hidden = YES;
        cell.line.frame = CGRectMake(CGRectGetMidX(cell.bounds), CGRectGetHeight(cell.bounds) - _lineMinHeight, 0.5f, _lineMinHeight);

    }
    return cell;
}



#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_scrollByDragging) {
        NSInteger row = (scrollView.contentOffset.x) / _lineSpan;
        [self setRealValueAtRow:row callback:YES];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _scrollByDragging = YES;
    _scrollOffset = scrollView.contentOffset;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)//拖拽时没有滑动动画
    {
        [self didEndDraggingScrollView:scrollView];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self didEndDraggingScrollView:scrollView];
}

- (void)didEndDraggingScrollView:(UIScrollView *)scrollView
{
    NSInteger row = (scrollView.contentOffset.x) / _lineSpan;
    if (scrollView.contentOffset.x > _scrollOffset.x && row < _totalRow - 1) {
        row += 1;
    }
    
    [self setRealValueAtRow:row callback:YES];
    [_collectionView setContentOffset:CGPointMake(row * _lineSpan, 0) animated:YES];
}



@end
