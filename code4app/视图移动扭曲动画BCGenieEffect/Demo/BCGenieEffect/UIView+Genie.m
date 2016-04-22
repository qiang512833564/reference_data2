//
//  UIView+Genie.m
//  BCGenieEffect
//
//  Created by Bartosz Ciechanowski on 23.12.2012.
//  Copyright (c) 2012 Bartosz Ciechanowski. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIView+Genie.h"


#pragma mark - Constants


/* Animation parameters
 *
 * Genie effect consists of two such subanimations: the curves subanimation and the slide subanimation.
 * There former one moves Bezier curves outlining the effect's shape, while the latter one slides
 * the subject view towards/from the destination/start rect. 
 
 * These parameters describe the percentages of progress at which the subanimations should start/end.
 * These values must be in range [0, 1]!
 *
 * Example: 
 * Assuming that duration of animation is set to 2 seconds then the curves subanimation will start
 * at 0.0 and will end at 0.8 seconds while the slide subanimation will start at 0.6 seconds and
 * will end at 2.0 seconds.
 */

static const double curvesAnimationStart = 0.0;
static const double curvesAnimationEnd = 0.4;
static const double slideAnimationStart = 0.3;
static const double slideAnimationEnd = 1.0;

/* Performance parameters
 *
 * Because the default linear interpolation of nontrivial CATransform3D causes them to act *wildly*
 * I've decided to use discrete animations, i.e. each frame is distinct and is calculated separately.
 * While this makes sure that animations behave correctly, it *may* cause some performance issues for
 * very long durations and/or large views.
 */

static const CGFloat kSliceSize = 10.0f; // height/width of a single slice
static const NSTimeInterval kFPS = 60.0; // assumed animation's FPS


/* Antialiasing parameter
 *
 * While there is a visible difference between 0.0 and 1.0 values in kRenderMargin constant, larger values
 * do not seem to provide any significant improvement in edges quality and will decrease performance.
 * The default value works great and you should change it only if you manage to convince yourself
 * that it does bring quality improvement.
 */

static const CGFloat kRenderMargin = 2.0;


#pragma mark - Structs & enums boilerplate

#define isEdgeVertical(d) (!((d) & 1))
#define isEdgeNegative(d) (((d) & 2))
#define axisForEdge(d) ((BCAxis)isEdgeVertical(d))
#define perpAxis(d) ((BCAxis)(!(BOOL)d))

typedef NS_ENUM(NSInteger, BCAxis) {
    BCAxisX = 0,
    BCAxisY = 1
};

// It's not an ego issue that I wanted to have my own CGPoints, it's just that it's easier
// to access specific axis by treating point as two element array, therefore I'm using union.
// Moreover, CGFloat is a typedefed float, and floats have much lower precision, causing slices
// to misalign occasionaly. Using doubles completely (?) removed the issue.
/*
 “联合”是一种特殊的类，也是一种构造类型的数据结构。在一个“联合”内可以定义多种不同的数据类型， 一个被说明为该“联合”类型的变量中，允许装入该“联合”所定义的任何一种数据，这些数据共享同一段内存，以达到节省空间的目的（还有一个节省空间的类型：位域）。 这是一个非常特殊的地方，也是联合的特征。另外，同struct一样，联合默认访问权限也是公有的，并且，也具有成员函数。
 */
typedef union BCPoint
{
    struct { double x, y; }; 
    double v[2];
}
BCPoint;

static inline BCPoint BCPointMake(double x, double y)
{
    BCPoint p; p.x = x; p.y = y; return p;
}

typedef union BCTrapezoid {
    struct { BCPoint a, b, c, d; };
    BCPoint v[4];
} BCTrapezoid;


typedef struct BCSegment {
    BCPoint a;
    BCPoint b;
} BCSegment;

static inline BCSegment BCSegmentMake(BCPoint a, BCPoint b)
{
    BCSegment s; s.a = a; s.b = b; return s;
}

typedef BCSegment BCBezierCurve;

static const int BCTrapezoidWinding[4][4] = {
    [BCRectEdgeTop]    = {0,1,2,3},
    [BCRectEdgeLeft]   = {2,0,3,1},
    [BCRectEdgeBottom] = {3,2,1,0},
    [BCRectEdgeRight]  = {1,3,0,2},
};


@implementation UIView (Genie)

#pragma mark - publics

- (void)genieInTransitionWithDuration:(NSTimeInterval)duration destinationRect:(CGRect)destRect destinationEdge:(BCRectEdge)destEdge completion:(void (^)())completion {
    
    [self genieTransitionWithDuration:duration
                                 edge:destEdge
                      destinationRect:destRect
                              reverse:NO
                           completion:completion];
}

- (void)genieOutTransitionWithDuration:(NSTimeInterval)duration startRect:(CGRect)startRect startEdge:(BCRectEdge)startEdge completion:(void (^)())completion {
    [self genieTransitionWithDuration:duration
                                 edge:startEdge
                      destinationRect:startRect
                              reverse:YES
                           completion:completion];
}

#pragma mark - privates


- (void) genieTransitionWithDuration:(NSTimeInterval) duration
                           edge:(BCRectEdge) edge
                     destinationRect:(CGRect)destRect
                             reverse:(BOOL)reverse
                          completion:(void (^)())completion
{
    assert(!CGRectIsNull(destRect));
    
    BCAxis axis = axisForEdge(edge);//判断移动是水平向的还是竖直向的
    BCAxis pAxis = perpAxis(axis);
    
    self.transform = CGAffineTransformIdentity;
    
    UIImage *snapshot = [self renderSnapshotWithMarginForAxis:axis];
    NSArray *slices = [self sliceImage:snapshot toLayersAlongAxis:axis];//将视图切割成若干片
    
    // Bezier calculations
    CGFloat xInset = axis == BCAxisY ? -kRenderMargin : 0.0f;
    CGFloat yInset = axis == BCAxisX ? -kRenderMargin : 0.0f;
//    NSLog(@"%f-----%f",self.bounds.size.height,destRect.size.height);
    CGRect marginedDestRect = CGRectInset(destRect, xInset*destRect.size.width/self.bounds.size.width, yInset*destRect.size.height/self.bounds.size.height);
    CGFloat endRectDepth = isEdgeVertical(edge) ? marginedDestRect.size.height : marginedDestRect.size.width;
    BCSegment aPoints = bezierEndPointsForTransition(edge, [self convertRect:CGRectInset(self.bounds, xInset, yInset) toView:self.superview]);
    
    BCSegment bEndPoints = bezierEndPointsForTransition(edge, marginedDestRect);
    BCSegment bStartPoints = aPoints;
    bStartPoints.a.v[axis] = bEndPoints.a.v[axis];
    bStartPoints.b.v[axis] = bEndPoints.b.v[axis];
   
    BCBezierCurve first = {aPoints.a, bStartPoints.a};//确定第一个点---从初始位置到结束位置
    BCBezierCurve second = {aPoints.b, bStartPoints.b};//确定第二个点
    
    // View hierarchy setup
    
    NSString *sumKeyPath = isEdgeVertical(edge) ? @"@sum.bounds.size.height" : @"@sum.bounds.size.width";
    CGFloat totalSize = [[slices valueForKeyPath:sumKeyPath] floatValue];//kvo---valueForKeyPath取得属性值
    
    CGFloat sign = isEdgeNegative(edge) ? -1.0 : 1.0;

    if (sign*(aPoints.a.v[axis] - bEndPoints.a.v[axis]) > 0.0f) {


        NSLog(@"Genie Effect ERROR: The distance between %@ edge of animated view and %@ edge of %@ rect is incorrect. Animation will not be performed!", edgeDescription(edge), edgeDescription(edge), reverse ? @"star" : @"destination");
        return;
    } else if (sign*(aPoints.a.v[axis] + sign*totalSize - bEndPoints.a.v[axis]) > 0.0f) {
        NSLog(@"Genie Effect Warning: The %@ edge of animated view overlaps %@ edge of %@ rect. Glitches may occur.",edgeDescription((edge + 2) % 4), edgeDescription(edge), reverse ? @"start" : @"destination");
    }
    
    UIView *containerView = [[UIView alloc] initWithFrame:[self.superview bounds]];
    containerView.clipsToBounds = self.superview.clipsToBounds; // if superview does it then we should probably do it as well
    containerView.backgroundColor = [UIColor clearColor];
    [self.superview insertSubview:containerView belowSubview:self];
    
    NSMutableArray *transforms = [NSMutableArray arrayWithCapacity:[slices count]];
    
    for (CALayer *layer in slices) {
        [containerView.layer addSublayer:layer];
        [transforms addObject:[NSMutableArray array]];
    }
    
    BOOL previousHiddenState = self.hidden;
    self.hidden = YES; // hide self throught animation, slices will be shown instead
    
    // Animation frames

    NSInteger totalIter = duration*kFPS;
    double tSignShift = reverse ? -1.0 : 1.0;
    
    for (int i = 0; i < totalIter; i++) {//这里是计算出动画values，为了保证动画每秒对应的transform
        
        double progress = ((double)i)/((double)totalIter - 1.0);        
        double t = tSignShift*(progress - 0.5) + 0.5;
        
        double curveP = progressOfSegmentWithinTotalProgress(curvesAnimationStart, curvesAnimationEnd, t);
        
        first.b.v[pAxis] = easeInOutInterpolate(curveP, bStartPoints.a.v[pAxis], bEndPoints.a.v[pAxis]);
        second.b.v[pAxis] = easeInOutInterpolate(curveP, bStartPoints.b.v[pAxis], bEndPoints.b.v[pAxis]);
        
        double slideP = progressOfSegmentWithinTotalProgress(slideAnimationStart, slideAnimationEnd, t);
        
        NSArray *trs = [self transformationsForSlices:slices
                                            edge:edge
                                        startPosition:easeInOutInterpolate(slideP, first.a.v[axis], first.b.v[axis])
                                            totalSize:totalSize
                                          firstBezier:first
                                         secondBezier:second
                                       finalRectDepth:endRectDepth];
        
        [trs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [transforms[idx] addObject:obj];
        }];
    }
    //通过片断移动缩放的动画形成
    // Animation firing
#if 1
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
    
        [containerView removeFromSuperview];
    
        CGSize startSize = self.frame.size;
        CGSize endSize = destRect.size;
    
        CGPoint startOrigin = self.frame.origin;
        CGPoint endOrigin = destRect.origin;
        
        if (! reverse) {
            CGAffineTransform transform = CGAffineTransformMakeTranslation(endOrigin.x - startOrigin.x, endOrigin.y - startOrigin.y); // move to destination
            transform = CGAffineTransformTranslate(transform, -startSize.width/2.0, -startSize.height/2.0); // move top left corner to origin
            transform = CGAffineTransformScale(transform, endSize.width/startSize.width, endSize.height/startSize.height); // scale
            transform = CGAffineTransformTranslate(transform, startSize.width/2.0, startSize.height/2.0); // move back
            
            self.transform = transform;
        }

        self.hidden = previousHiddenState;
        
        if (completion) {
            completion();
        }
    }];
#if 0
    CALayer *layer = slices[0];
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    anim.duration = duration;
    anim.values = transforms[0];
    anim.calculationMode = kCAAnimationDiscrete;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    [layer addAnimation:anim forKey:@"transform"];
#endif
    [slices enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
        CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        anim.duration = duration;
        anim.values = transforms[idx];
        anim.calculationMode = kCAAnimationDiscrete;
        anim.removedOnCompletion = NO;
        anim.fillMode = kCAFillModeForwards;
        [layer addAnimation:anim forKey:@"transform"];
    }];
    
    [CATransaction commit];
#endif
}


- (UIImage *) renderSnapshotWithMarginForAxis:(BCAxis)axis
{
    CGSize contextSize = self.frame.size;
    CGFloat xOffset = 0.0f;
    CGFloat yOffset = 0.0f;
    
    if (axis == BCAxisY) {
        xOffset = kRenderMargin;
        contextSize.width += 2.0*kRenderMargin;
    } else {
        yOffset = kRenderMargin;
        contextSize.height += 2.0*kRenderMargin;
    }
    
    UIGraphicsBeginImageContextWithOptions(contextSize, NO, 0.0); // if you want to see border added for antialiasing pass YES as second param
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, xOffset, yOffset);
    
    [self.layer renderInContext:context];
    
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshot;
}


- (NSArray *) sliceImage: (UIImage *) image toLayersAlongAxis: (BCAxis) axis
{
    CGFloat totalSize = axis == BCAxisY ? image.size.height : image.size.width;
    
    BCPoint origin = {0.0, 0.0};
    origin.v[axis] = kSliceSize;
    
    CGFloat scale = image.scale;
    CGSize sliceSize = axis == BCAxisY ? CGSizeMake(image.size.width, kSliceSize) : CGSizeMake(kSliceSize, image.size.height);
    /*
     使用ceil函数。ceil(x)返回的是大于x的最小整数。搜索
     ceil(2.4) = 3
     */
    NSInteger count = (NSInteger)ceilf(totalSize/kSliceSize);//表示10个单位截取一个单元
    
    NSMutableArray *slices = [NSMutableArray arrayWithCapacity:count];
    
//    UIImageView *imageView = [[UIImageView alloc]init];
//    imageView.center = CGPointMake(self.center.x, self.center.y + 100);
//    imageView.bounds = CGRectMake(0, 0, 100, 100);
//    imageView.backgroundColor = [UIColor blackColor];
//    UIWindow *window = [UIApplication sharedApplication].keyWindow;
//    [window addSubview:imageView];
 
    for (int i = 0; i < count; i++) {
        CGRect rect = {i*origin.x*scale, i*origin.y*scale, sliceSize.width*scale, sliceSize.height*scale};
        UIImage *sliceImage = [UIImage imageWithCGImage: CGImageCreateWithImageInRect(image.CGImage, rect)
                                                  scale:image.scale
                                            orientation:image.imageOrientation];
        
        //NSLog(@"%f---------%f",image.scale, scale);
        CALayer *layer = [CALayer layer];
        layer.anchorPoint = CGPointZero;
        layer.bounds = CGRectMake(0.0, 0.0, sliceImage.size.width, sliceImage.size.height);
        layer.contents = (__bridge id)(sliceImage.CGImage);
        layer.contentsScale = image.scale;
        [slices addObject:layer];
    }
    
    return slices;
}


- (NSArray *) transformationsForSlices: (NSArray *) slices
                             edge: (BCRectEdge) edge
                         startPosition: (CGFloat) startPosition
                             totalSize: (CGFloat) totalSize
                           firstBezier: (BCBezierCurve) first
                          secondBezier: (BCBezierCurve) second
                        finalRectDepth: (CGFloat) rectDepth
{
    NSMutableArray *transformations = [NSMutableArray arrayWithCapacity:[slices count]];
    
    BCAxis axis = axisForEdge(edge);
    
    CGFloat rectPartStart = first.b.v[axis];
    CGFloat sign = isEdgeNegative(edge) ? -1.0 : 1.0;

    assert(sign*(startPosition - rectPartStart) <= 0.0);
    
    __block CGFloat position = startPosition;
    __block BCTrapezoid trapezoid = {0};
    trapezoid.v[BCTrapezoidWinding[edge][0]] = bezierAxisIntersection(first, axis, position);
    trapezoid.v[BCTrapezoidWinding[edge][1]] = bezierAxisIntersection(second, axis, position);
    
    NSEnumerationOptions enumerationOptions = isEdgeNegative(edge) ? NSEnumerationReverse : 0;
    
    [slices enumerateObjectsWithOptions:enumerationOptions usingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
        
        CGFloat size = isEdgeVertical(edge) ? layer.bounds.size.height : layer.bounds.size.width;
        CGFloat endPosition = position + sign*size; // we're not interested in slices' origins since they will be moved around anyway
        
        double overflow = sign*(endPosition - rectPartStart);
        
        if (overflow <= 0.0f) { // slice is still in bezier part
            trapezoid.v[BCTrapezoidWinding[edge][2]] = bezierAxisIntersection(first, axis, endPosition);
            trapezoid.v[BCTrapezoidWinding[edge][3]] = bezierAxisIntersection(second, axis, endPosition);
        }
        else { // final rect part
            CGFloat shrunkSliceDepth = overflow*rectDepth/(double)totalSize; // how deep inside final rect "bottom" part of slice is
            
            trapezoid.v[BCTrapezoidWinding[edge][2]] = first.b;
            trapezoid.v[BCTrapezoidWinding[edge][2]].v[axis] += sign*shrunkSliceDepth;
            
            trapezoid.v[BCTrapezoidWinding[edge][3]] = second.b;
            trapezoid.v[BCTrapezoidWinding[edge][3]].v[axis] += sign*shrunkSliceDepth;
        }
        
        CATransform3D transform = [self transformRect:layer.bounds toTrapezoid:trapezoid];
        [transformations addObject:[NSValue valueWithCATransform3D:transform]];
        
        trapezoid.v[BCTrapezoidWinding[edge][0]] = trapezoid.v[BCTrapezoidWinding[edge][2]]; // next one starts where previous one ends
        trapezoid.v[BCTrapezoidWinding[edge][1]] = trapezoid.v[BCTrapezoidWinding[edge][3]];
        
        position = endPosition;
    }];
    
    if (isEdgeNegative(edge)) {
        return [[transformations reverseObjectEnumerator] allObjects];
    }
    
    return transformations;
}

// based on http://stackoverflow.com/a/12820877/558816
// X and Y is always assumed to be 0, that's why it's been dropped in the calculations
// All calculations are on doubles, to make sure that we get as much precsision as we can
// since even minor errors in transform matrix may cause major glitches
- (CATransform3D) transformRect: (CGRect) rect toTrapezoid: (BCTrapezoid) trapezoid
{

    double W = rect.size.width;
    double H = rect.size.height;
    
    double x1a = trapezoid.a.x;
    double y1a = trapezoid.a.y;
    
    double x2a = trapezoid.b.x;
    double y2a = trapezoid.b.y;
    
    double x3a = trapezoid.c.x;
    double y3a = trapezoid.c.y;
    
    double x4a = trapezoid.d.x;
    double y4a = trapezoid.d.y;
    
    double y21 = y2a - y1a,
    y32 = y3a - y2a,
    y43 = y4a - y3a,
    y14 = y1a - y4a,
    y31 = y3a - y1a,
    y42 = y4a - y2a;
    
    
    double a = -H*(x2a*x3a*y14 + x2a*x4a*y31 - x1a*x4a*y32 + x1a*x3a*y42);
    double b = W*(x2a*x3a*y14 + x3a*x4a*y21 + x1a*x4a*y32 + x1a*x2a*y43);
    double c = - H*W*x1a*(x4a*y32 - x3a*y42 + x2a*y43);
    
    double d = H*(-x4a*y21*y3a + x2a*y1a*y43 - x1a*y2a*y43 - x3a*y1a*y4a + x3a*y2a*y4a);
    double e = W*(x4a*y2a*y31 - x3a*y1a*y42 - x2a*y31*y4a + x1a*y3a*y42);
    double f = -(W*(x4a*(H*y1a*y32) - x3a*(H)*y1a*y42 + H*x2a*y1a*y43));
    
    double g = H*(x3a*y21 - x4a*y21 + (-x1a + x2a)*y43);
    double h = W*(-x2a*y31 + x4a*y31 + (x1a - x3a)*y42);
    double i = H*(W*(-(x3a*y2a) + x4a*y2a + x2a*y3a - x4a*y3a - x2a*y4a + x3a*y4a));
    
    const double kEpsilon = 0.0001;
    
    if(fabs(i) < kEpsilon) {
        i = kEpsilon* (i > 0 ? 1.0 : -1.0);
    }
    
    CATransform3D transform = {a/i, d/i, 0, g/i, b/i, e/i, 0, h/i, 0, 0, 1, 0, c/i, f/i, 0, 1.0};
    
    return transform;
}


#pragma mark - C convinience functions

static BCSegment bezierEndPointsForTransition(BCRectEdge edge, CGRect endRect)
{
    switch (edge) {
        case BCRectEdgeTop:
            return BCSegmentMake(BCPointMake(CGRectGetMinX(endRect), CGRectGetMinY(endRect)), BCPointMake(CGRectGetMaxX(endRect), CGRectGetMinY(endRect)));
        case BCRectEdgeBottom:
            return BCSegmentMake(BCPointMake(CGRectGetMaxX(endRect), CGRectGetMaxY(endRect)), BCPointMake(CGRectGetMinX(endRect), CGRectGetMaxY(endRect)));
        case BCRectEdgeRight:
            return BCSegmentMake(BCPointMake(CGRectGetMaxX(endRect), CGRectGetMinY(endRect)), BCPointMake(CGRectGetMaxX(endRect), CGRectGetMaxY(endRect)));
        case BCRectEdgeLeft:
            return BCSegmentMake(BCPointMake(CGRectGetMinX(endRect), CGRectGetMaxY(endRect)), BCPointMake(CGRectGetMinX(endRect), CGRectGetMinY(endRect)));
    }
    
    assert(0); // should never happen
}

static inline CGFloat progressOfSegmentWithinTotalProgress(CGFloat a, CGFloat b, CGFloat t)
{
    assert(b > a);
    
    return MIN(MAX(0.0, (t - a)/(b - a)), 1.0);
}

static inline CGFloat easeInOutInterpolate(float t, CGFloat a, CGFloat b)
{
    assert(t >= 0.0 && t <= 1.0); // we don't want any other values
    
    CGFloat val = a + t*t*(3.0 - 2.0*t)*(b - a);
    
    return b > a ? MAX(a,  MIN(val, b)) : MAX(b,  MIN(val, a)); // clamping, since numeric precision might bite here
}

static BCPoint bezierAxisIntersection(BCBezierCurve curve, BCAxis axis, CGFloat axisPos)
{
    assert((axisPos >= curve.a.v[axis] && axisPos <= curve.b.v[axis]) || (axisPos >= curve.b.v[axis] && axisPos <= curve.a.v[axis]));
    
    BCAxis pAxis = perpAxis(axis);
    
    BCPoint c1, c2;
    c1.v[pAxis] = curve.a.v[pAxis];
    c1.v[axis] = (curve.a.v[axis] + curve.b.v[axis])/2.0;
    
    c2.v[pAxis] = curve.b.v[pAxis];
    c2.v[axis] = (curve.a.v[axis] + curve.b.v[axis])/2.0;
    
    double t = (axisPos - curve.a.v[axis])/(curve.b.v[axis] - curve.a.v[axis]); // first approximation - treating curve as linear segment
    
    const int kIterations = 3; // Newton-Raphson iterations
    
    for (int i = 0; i < kIterations; i++) {
        double nt = 1.0 - t;
        
        double f = nt*nt*nt*curve.a.v[axis] + 3.0*nt*nt*t*c1.v[axis] + 3.0*nt*t*t*c2.v[axis] + t*t*t*curve.b.v[axis] - axisPos;
        double df = -3.0*(curve.a.v[axis]*nt*nt + c1.v[axis]*(-3.0*t*t + 4.0*t - 1.0) + t*(3.0*c2.v[axis]*t - 2.0*c2.v[axis] - curve.b.v[axis]*t));
        
        t -= f/df;
    }
    
    assert(t >= 0 && t <= 1.0);
    
    double nt = 1.0 - t;
    double intersection = nt*nt*nt*curve.a.v[pAxis] + 3.0*nt*nt*t*c1.v[pAxis] + 3.0*nt*t*t*c2.v[pAxis] + t*t*t*curve.b.v[pAxis];
    
    BCPoint ret;
    ret.v[axis] = axisPos;
    ret.v[pAxis] = intersection;
    
    return ret;
}

static inline NSString * edgeDescription(BCRectEdge edge)
{
    NSString *rectEdge[] = {
        [BCRectEdgeBottom] = @"bottom",
        [BCRectEdgeTop] = @"top",
        [BCRectEdgeRight] = @"right",
        [BCRectEdgeLeft] = @"left",
    };
    
    return rectEdge[edge];
}

@end
