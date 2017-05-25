//
// JXEmotionManager.m
//

#import "JXEmotionManager.h"

@implementation JXEmotionManager

- (id)initWithType:(EMEmotionType)Type
        emotionRow:(NSInteger)emotionRow
        emotionCol:(NSInteger)emotionCol
          emotions:(NSArray*)emotions {
    if (self = [super init]) {
        _emotionType = Type;
        _emotionRow = emotionRow;
        _emotionCol = emotionCol;
        _emotions = emotions;
    }
    return self;
}

@end
