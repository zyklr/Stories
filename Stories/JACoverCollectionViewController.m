//
//  JACoverCollectionViewController.m
//  Stories
//
//  Created by LANGLADE Antonin on 12/11/2014.
//  Copyright (c) 2014 Jb & Anto. All rights reserved.
//

#import "JACoverCollectionViewController.h"

@interface JACoverCollectionViewController ()

@property UIGestureRecognizerState stateLongTap;
@property BOOL animatedLoader;
@property BOOL firstTime;

@end

@implementation JACoverCollectionViewController



static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.manager = [JAManagerData sharedManager];
    
    self.firstTime = YES;
    self.animatedLoader = NO;
    self.currentIndex = 0;
    self.stateLongTap = UIGestureRecognizerStatePossible;

    
    // Layout View
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(CGRectGetWidth(self.view.bounds),  CGRectGetHeight(self.view.bounds));
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    // Collection View
    self.collectionView = [[UICollectionView alloc] initWithFrame:[[UIScreen mainScreen] bounds] collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.bounces = NO;
    self.collectionView.collectionViewLayout = layout;

    
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerClass:[JACoverCollectionViewCell class] forCellWithReuseIdentifier:@"CoverCell"];
    self.collectionView.pagingEnabled = YES;

    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    // Name View
    self.nameViewLBL = [[UILabel alloc]initWithFrame:CGRectMake(25, 25, self.view.bounds.size.width, 50)];
    self.nameViewLBL.textColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
    self.nameViewLBL.font = [UIFont fontWithName:@"Circular-Std-Book" size:19.0];
    self.nameViewLBL.text = @"Publications";
    [self.view addSubview:self.nameViewLBL];
    
    // Loader View
    self.loaderView = [[JALoaderView alloc]initWithFrame:CGRectMake(0, 0, 160, 160)];
    self.loaderView.delegate = self;
    [self.view addSubview:self.loaderView];
    
    

    // Gesture recognizer
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressDetected:)];
    longPressRecognizer.minimumPressDuration = .3;
    longPressRecognizer.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:longPressRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)longPressDetected:(UITapGestureRecognizer *)sender{
    
    CGPoint touchPosition = [sender locationInView:self.view];
    
    [self.loaderView movePosition:touchPosition];
    [self.loaderView setState:sender.state];

}
-(void)loadNextView{
    NSLog(@"Hiya!");
    self.manager.currentStorie = (int)self.currentIndex;
    [self performSegueWithIdentifier:@"JACoverPush" sender:self];
}

-(void)animateScrollView:(JAAnimDirection)direction{
    
    if((self.currentIndex >= 3 && direction == JAAnimDirectionLeft) || (self.currentIndex == 0 && direction == JAAnimDirectionRight)){
        return;
    }
    
    direction==JAAnimDirectionRight?self.currentIndex--:self.currentIndex++;

    NSIndexPath *nextItem = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];

    [self.collectionView scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JACoverCollectionViewCell *myCell = [collectionView
                                    dequeueReusableCellWithReuseIdentifier:@"CoverCell"
                                    forIndexPath:indexPath];
    
    long row = [indexPath row];
    
    UIImage *background = [UIImage imageNamed:[[self.manager.data.stories[row] cover] background]];
    UIImage *foreground = [UIImage imageNamed:[[self.manager.data.stories[row] cover] foreground]];
    
    myCell.backgroundIV.image = background;
    myCell.foregroundIV.image = foreground;
    myCell.titleLBL.text = [[self.manager.data.stories[row] cover] title];
    myCell.locationLBL.text = [[self.manager.data.stories[row] cover] location];

    return myCell;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.manager.data.stories count];
}


#pragma mark <UICollectionViewDelegate>
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
//    NSLog(@"Decelerate");
    [self.cellToAnimate animateEnter];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(JACoverCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    self.cellToAnimate = cell;

    if(self.firstTime){
        [cell animateEnter];
        self.firstTime = NO;
    }
    
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(JACoverCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"EndAppear %ld",(long)indexPath.row);
    [cell resetAnimation];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSLog(@"test");
//    NSLog(@"Offset %i",(int)(scrollView.contentOffset.x/self.collectionView.frame.size.width));

    self.currentIndex = (int)(scrollView.contentOffset.x/self.collectionView.frame.size.width);
    NSLog(@"INDEXXX %li",(long)self.currentIndex);
}

-(IBAction)returnFromChapterView:(UIStoryboardSegue*)segue{

}
-(BOOL)prefersStatusBarHidden{
    return YES;
}


@end
