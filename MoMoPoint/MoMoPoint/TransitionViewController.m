//
//  TransitionViewController.m
//  MoMoPoint
//
//  Created by fighting on 17/5/19.
//  Copyright © 2017年 李鹏举. All rights reserved.
//

#import "TransitionViewController.h"
#import "TransitionAnimation.h"
#import "CardView.h"

#define sizePercent 0.05
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height
#define OFFSET_Y 15.0
#define IMAGE_NUMBER 9
#define DISTANCE_X 60.0

@interface TransitionViewController ()<UIViewControllerTransitioningDelegate>

@property(nonatomic, strong)NSMutableArray * cards;
@property(nonatomic, strong)NSMutableArray * showCards;
@property(nonatomic, assign)NSUInteger currentIndex;
@property(nonatomic, assign)NSInteger showCardsNumber;
@property(nonatomic, assign)CGPoint initialLocation;
@property(nonatomic, strong)NSMutableArray * imageArray;
@property(nonatomic, strong)NSMutableArray * alphaArray;
@end

@implementation TransitionViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.transitioningDelegate = self;
    }
    return self;
}
-(NSMutableArray *)imageArray
{
    if (!_imageArray) {
        _imageArray = [[NSMutableArray alloc]init];
        for (int i = 0; i < IMAGE_NUMBER; i++) {
            [_imageArray addObject:[NSString stringWithFormat:@"image%d.jpg",i]];
        }
    }
    return _imageArray;
}

-(NSMutableArray *)alphaArray
{
    if (!_alphaArray) {
        _alphaArray = [[NSMutableArray alloc]initWithArray:@[@(0),@(0.35),@(0.70),@(1.0)]];
    }
    return _alphaArray;
}

-(NSMutableArray *)cards
{
    if (!_cards) {
        _cards = [[NSMutableArray alloc]init];
        for (int i = 0; i < IMAGE_NUMBER; i++) {
            CardView * cardView = [[CardView alloc]initWithFrame:CGRectMake(0, 0, 200, 300)];
            cardView.center = CGPointMake(WIDTH/2.0, HEIGHT/2.0 + OFFSET_Y*(IMAGE_NUMBER-1-i));
            cardView.transform = CGAffineTransformMakeScale(1-sizePercent*(IMAGE_NUMBER-i), 1-sizePercent*(IMAGE_NUMBER-i));
            cardView.layer.cornerRadius = 10;
            cardView.layer.masksToBounds = YES;
            cardView.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:self.imageArray[i]].CGImage);
            [_cards addObject:cardView];
        }
    }
    return _cards;
}

-(NSMutableArray *)showCards
{
    if (!_showCards) {
        _showCards = [[NSMutableArray alloc]init];
    }
    return _showCards;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置view背景颜色
    self.view.backgroundColor = [UIColor grayColor];
    //设置预期显示的cardView数目
    self.showCardsNumber = 4;
    //添加视图
    [self addCardViews];
    
}
//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    [self dismissViewControllerAnimated:YES completion:nil];
//}
- (void)addCardViews
{
    if (IMAGE_NUMBER < _showCardsNumber) {
        NSInteger removeNum = _showCardsNumber - IMAGE_NUMBER;
        _showCardsNumber = IMAGE_NUMBER;
        for (int i = 0; i < removeNum; i++) {
            [self.alphaArray removeObjectAtIndex:0];
        }
        for (int i = 0; i < _showCardsNumber; i++) {
            CardView * cardView = self.cards[i];
            cardView.alpha = [self.alphaArray[i] floatValue];
            [self.view addSubview:cardView];
            if (i == _showCardsNumber-1) {
                [self addPanGestureWithView:cardView];
                self.currentIndex = _showCardsNumber-1;
            }
        }
    }else{
        for (int i = 0; i < _showCardsNumber; i++) {
            CardView * cardView = self.cards[IMAGE_NUMBER-_showCardsNumber+i];
            cardView.alpha = [self.alphaArray[i] floatValue];
            [self.view addSubview:cardView];
            if (i == _showCardsNumber-1) {
                [self addPanGestureWithView:cardView];
                self.currentIndex = IMAGE_NUMBER-1;
            }
        }
    }
    
    
}

- (void)addPanGestureWithView:(CardView *)cardView
{
    //添加拖动手势
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panHandle:)];
    [cardView addGestureRecognizer:pan];
}

-(void)panHandle:(UIPanGestureRecognizer *)pan{
    CardView * cardView = self.cards[self.currentIndex];
    //开始拖动
    if (pan.state == UIGestureRecognizerStateBegan) {
        
    }
    //拖动中
    {
        //给顶部视图添加动画
        CGPoint transLcation = [pan translationInView:cardView];
        cardView.center = CGPointMake(cardView.center.x + transLcation.x, cardView.center.y + transLcation.y);
        CGFloat XOffPercent = (cardView.center.x-WIDTH/2.0)/(WIDTH/2.0);
        CGFloat rotation = M_PI_2/4*XOffPercent;
        cardView.transform = CGAffineTransformMakeRotation(rotation);
        [pan setTranslation:CGPointZero inView:cardView];
        //给其余底部视图添加动画
        [self animationBlowViewWithXOffPercent:fabs(XOffPercent)];
        
    }
    //拖动结束
    if (pan.state == UIGestureRecognizerStateEnded) {
        //视图不移除
        if (cardView.center.x > DISTANCE_X && cardView.center.x < WIDTH - DISTANCE_X) {
            [UIView animateWithDuration:0.25 animations:^{
                cardView.center = CGPointMake(WIDTH/2.0, HEIGHT/2.0);
                cardView.transform = CGAffineTransformMakeRotation(0);
                [self animationBlowViewWithXOffPercent:0];
            }];
        }
        //移除拖动视图
        else{
            //视图在屏幕左侧移除
            if (cardView.center.x < DISTANCE_X) {
                [UIView animateWithDuration:0.25 animations:^{
                    cardView.center = CGPointMake(0-200, cardView.center.y);
                }];
            }
            //视图在屏幕右侧移除
            else{
                [UIView animateWithDuration:0.25 animations:^{
                    cardView.center = CGPointMake(WIDTH+200, cardView.center.y);
                }];
            }
            [self animationBlowViewWithXOffPercent:1];
            [self performSelector:@selector(cardRemove:) withObject:cardView afterDelay:0.25];
        }
    }
}

- (void)animationBlowViewWithXOffPercent:(CGFloat)XOffPercent
{
    for (int i = 0; i < _showCardsNumber - 1; i++) {
        CardView * otherView = self.cards[self.currentIndex-i-1];
        //透明度
        CGFloat alpha = [self.alphaArray[_showCardsNumber-i-2] floatValue] + ([self.alphaArray[_showCardsNumber-i-1] floatValue] - [self.alphaArray[_showCardsNumber-i-2] floatValue])*XOffPercent;
        otherView.alpha = alpha;
        //中心
        CGPoint point = CGPointMake(WIDTH/2.0, HEIGHT/2.0 + OFFSET_Y*(i+1) - OFFSET_Y*XOffPercent);
        otherView.center = point;
        //缩放大小
        CGFloat scale = 1-sizePercent*(i+1)+ XOffPercent*sizePercent;
        otherView.transform = CGAffineTransformMakeScale(scale, scale);
    }
}

-(void)cardRemove:(CardView *)card{
    if (card) {
        [card removeFromSuperview];
    }
    self.currentIndex--;
    if ((NSInteger)self.currentIndex < 0) {
        return;
    }
    [self addPanGestureWithView:self.cards[self.currentIndex]];
    if ((NSInteger)(self.currentIndex-_showCardsNumber+1) >= 0) {
        //添加一个视图
        CardView *cardView = self.cards[self.currentIndex-_showCardsNumber+1];
        cardView.center = CGPointMake(WIDTH/2.0, HEIGHT/2.0 + OFFSET_Y*(_showCardsNumber-1));
        cardView.transform = CGAffineTransformMakeScale(1-sizePercent*(_showCardsNumber-1), 1-sizePercent*(_showCardsNumber-1));
        cardView.alpha = 0;
        [self.view addSubview:cardView];
        [self.view insertSubview:cardView belowSubview:self.cards[self.currentIndex-_showCardsNumber+2]];
    }else{
        if (IMAGE_NUMBER < _showCardsNumber) {
            _showCardsNumber--;
            [self.alphaArray removeObjectAtIndex:0];
        }else{
            _showCardsNumber--;
            if (_showCardsNumber < 4) {
                [self.alphaArray removeObjectAtIndex:0];
            }
        }
        
    }
}

#pragma mark -- UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [TransitionAnimation transitionWithTransitionType:TransitionTypePresent];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [TransitionAnimation transitionWithTransitionType:TransitionTypeDismiss];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
