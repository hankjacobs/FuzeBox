//
//  CTRLPanelsViewController.m
//  Breaker Buddy
//
//  Created by Hank Jacobs on 10/27/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLPanelsViewController.h"
#import "CTRLEditPanelViewController.h"
#import "CTRLFetchedResultsCollectionViewDelegateManager.h"
#import "CTRLBreakersViewController.h"
#import "CTRLPanelCollectionViewCell.h"
#import "CTRLDataStack.h"
#import "Panel.h"
#import "Panel+Helpers.h"
#import "CTRLPanelSnapshotGenerator.h"
#import "UIColor+UIColorFromRGB.h"
#import "House.h"
#import "Breaker.h"

@interface CTRLPanelsViewController ()<UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate, CTRLPanelCollectionViewCellDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;
@property (nonatomic, strong) NSFetchRequest *fetchRequest;
@property (nonatomic, strong) Panel *pendingDeletePanel;
@property (nonatomic, strong) NSArray *insertedIndexPaths;
@property (nonatomic, assign, getter = isDragging) BOOL dragging;

@end
@implementation CTRLPanelsViewController
@synthesize fetchedResultsController = _fetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeWillChange:) name:USMStoreWillChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeDidChange:) name:USMStoreDidChangeNotification object:nil];
    
    self.navigationController.delegate = self;
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = self.house.name;
    
    [(UICollectionViewFlowLayout *)self.collectionViewLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    [self.revealButtonItem setTarget:self.revealViewController];
    [self.revealButtonItem setAction:@selector(revealToggle:)];
    [self.navigationController.navigationBar addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    self.fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Panel"];
    self.fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]];
    self.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"house = %@", self.house];
    
    [self fetchPanels];
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.hidesForSinglePage = YES;
    self.pageControl.currentPageIndicatorTintColor = self.collectionView.tintColor;
    self.pageControl.pageIndicatorTintColor = [UIColor colorWithR:178 g:178 b:178];
    self.pageControl.center = CGPointMake(self.view.center.x, self.pageControl.center.y);
    
    self.pageControl.numberOfPages = self.fetchedResultsController.fetchedObjects.count;
    
    [self.view addSubview:self.pageControl];
    [self.view bringSubviewToFront:self.pageControl];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    
    if (!self.house) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    if (!self.fetchedResultsController) {
        UIView *loadingView = [[UIView alloc] initWithFrame:self.collectionView.bounds];
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicatorView.center = loadingView.center;
        
        [loadingView addSubview:activityIndicatorView];
        self.collectionView.backgroundView = loadingView;
        
        self.navigationItem.leftBarButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
    
    self.pageControl.frame = CGRectMake(self.pageControl.frame.origin.x, CGRectGetMaxY(self.collectionView.bounds)-CGRectGetHeight(self.pageControl.frame) - 10, CGRectGetWidth(self.pageControl.frame), CGRectGetHeight(self.pageControl.frame));
    
    if (self.isEditing) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    void (^styleBlock)();
    if (editing) {
        
        UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTapped:)];
        [self.navigationItem setLeftBarButtonItem:leftBarButton animated:animated];
        self.revealViewController.panGestureRecognizer.enabled = NO;
        
        styleBlock = ^(){
            self.navigationController.navigationBar.barTintColor = [UIColor defaultEditingNavigationBarColor];
            self.revealViewController.frontViewStatusBarBackgroundColor = [UIColor defaultEditingNavigationBarColor];
            self.collectionView.backgroundColor = [UIColor defaultEditingCollectionViewColor];
            self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        };
    }
    else {
        
        [self.navigationItem setLeftBarButtonItem:self.revealButtonItem animated:YES];
        self.revealViewController.panGestureRecognizer.enabled = YES;
        
        styleBlock = ^(){
            self.navigationController.navigationBar.barTintColor = [UIColor defaultNavigationBarColor];
            self.revealViewController.frontViewStatusBarBackgroundColor = [UIColor defaultNavigationBarColor];
            self.collectionView.backgroundColor = [UIColor defaultCollectionViewBackgroundColor];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
        };
    }
    
    if (animated) {
        [UIView animateWithDuration:.3 animations:styleBlock];
    }
    else {
        styleBlock();
    }
    
    for (CTRLPanelCollectionViewCell *cell in self.collectionView.visibleCells) {
        [cell setEditing:editing animated:YES];
    }
}

#pragma mark - Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Panel *panel = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (self.editing) {
        [self editPanel:panel];
    }
    else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CTRLBreakersViewController *breakersViewController = (CTRLBreakersViewController *)[storyboard instantiateViewControllerWithIdentifier:@"breakers"];
        breakersViewController.panel = panel;
        
        [self.navigationController pushViewController:breakersViewController animated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.bounds.size.width;
    NSInteger pageNumber = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = pageNumber;
}

#pragma mark - Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.fetchedResultsController.fetchedObjects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const reuseIdentifier = @"cell";
    
    Panel *panel = [self.fetchedResultsController objectAtIndexPath:indexPath];
    CTRLPanelCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    if (panel.panelType == PanelHorizontalSingleRow || panel.panelType == PanelHorizontalDoubleRow) {
        if (panel.breakers.count) {
            cell.panelImageView.image = [UIImage imageNamed:@"newPanelBlankWide"];
            cell.panelSnapshot = [CTRLPanelSnapshotGenerator snapshotForPanel:panel];
            
        }
        else {
            if (panel.panelType == PanelHorizontalDoubleRow) {
                cell.panelImageView.image = [UIImage imageNamed:@"newPanelDoubleWide"];
            }
            else {
                cell.panelImageView.image =  [UIImage imageNamed:@"newPanelSingleWide"];
            }
        }

    }
    else {
        if (panel.breakers.count) {
            cell.panelImageView.image = [UIImage imageNamed:@"newPanelBlankTall"];
            cell.panelSnapshot = [CTRLPanelSnapshotGenerator snapshotForPanel:panel];
        }
        else {
            if (panel.panelType == PanelVerticalDoubleRow) {
                cell.panelImageView.image = [UIImage imageNamed:@"newPanelDoubleTall"];
            }
            else {
                cell.panelImageView.image = [UIImage imageNamed:@"newPanelSingleTall"];
            }

        }
    }
    
    cell.panelName = panel.name;
    cell.editing = self.isEditing;
    cell.delegate = self;
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = self.collectionView.frame.size;
    
    return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    
    return insets;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
}

#pragma mark - LXCollectionViewControllerDelegate

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    Panel *draggedPanel = [self.fetchedResultsController objectAtIndexPath:fromIndexPath];
    Panel *targetPanel = [self.fetchedResultsController objectAtIndexPath:toIndexPath];
    
    if (fromIndexPath.row < toIndexPath.row) {
        NSNumber *targetIndex = targetPanel.index;
        NSArray *allPanels = [self.house.panels allObjects];
        NSArray *affectedPanels = [allPanels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"index <= %@", targetIndex]];
        
        for (Panel *panel in affectedPanels) {
            panel.index = @(panel.index.intValue-1);
        }
        draggedPanel.index = targetIndex;
    }
    else {
        NSNumber *targetIndex = targetPanel.index;
        NSNumber *originalIndex = draggedPanel.index;
        
        NSArray *allPanels = [self.house.panels allObjects];
        NSArray *affectedPanels = [allPanels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"index >= %@ AND index <= %@", targetIndex, originalIndex]];
        
        for (Panel *panel in affectedPanels) {
            panel.index = @(panel.index.intValue+1);
        }
        
        draggedPanel.index = targetIndex;
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.isEditing;
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    self.dragging = YES;
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.fetchedResultsController.managedObjectContext performBlockAndWait:^{
        NSError *error;
        [self.fetchedResultsController.managedObjectContext save:&error];
    }];
    
    [self.collectionView reloadData];
    [self.collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:YES];
    self.dragging = NO;
}

#pragma mark - Navigation

- (void)addTapped:(UIBarButtonItem *)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CTRLEditPanelViewController *editPanelViewController = (CTRLEditPanelViewController *)[storyboard instantiateViewControllerWithIdentifier:@"editPanelController"];

    NSArray *existingPanels = [self.house.panels allObjects];
    NSNumber *highestIndex = [existingPanels valueForKeyPath:@"@max.index"];
    
    NSManagedObjectContext *moc = [[CTRLDataStack sharedDataStack] scratchContext];
    Panel *panel = [NSEntityDescription insertNewObjectForEntityForName:@"Panel"
                                                 inManagedObjectContext:moc];
    if (self.house.panels.count)
        panel.name = @"Subpanel";
    else
        panel.name = @"Main Panel";
    
    panel.house = (House *)[moc objectWithID:self.house.objectID];
    panel.index = @(highestIndex.intValue+1);
    
    editPanelViewController.panel = panel;
    editPanelViewController.title = @"New Panel";
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:editPanelViewController];
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)editPanel:(Panel *)panel
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CTRLEditPanelViewController *editPanelViewController = (CTRLEditPanelViewController *)[storyboard instantiateViewControllerWithIdentifier:@"editPanelController"];

    NSManagedObjectContext *moc = [[CTRLDataStack sharedDataStack] scratchContext];
    Panel *scratchPanel = (Panel *)[moc objectWithID:panel.objectID];
    
    editPanelViewController.panel = scratchPanel;
    editPanelViewController.title = @"Edit Panel";
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:editPanelViewController];
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addPanelSegue"]) {
        CTRLEditPanelViewController *editPanelViewController = segue.destinationViewController;
        NSManagedObjectContext *moc = [[CTRLDataStack sharedDataStack] scratchContext];
        Panel *panel = [NSEntityDescription insertNewObjectForEntityForName:@"Panel"
                                                         inManagedObjectContext:moc];
        editPanelViewController.panel = panel;
        
    }
    else if ([segue.identifier isEqualToString:@"editPanelSegue"]) {
        CTRLEditPanelViewController *editPanelViewController = segue.destinationViewController;
        NSArray *visibleItems = [self.collectionView indexPathsForVisibleItems];
        NSIndexPath *indexPath = (visibleItems.count ? [visibleItems objectAtIndex:0] : nil);
        
        //TODO: Something doesn't feel right about this error handling.
        if (indexPath) {
            editPanelViewController.panel = [self.fetchedResultsController objectAtIndexPath:indexPath];
        }
    }
}

#pragma mark - Setter

- (void)setHouse:(House *)house
{
    _house =  house;
    
    if (house) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

#pragma mark - animator

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    if ([fromVC isKindOfClass:[CTRLPanelsViewController class]] && [toVC isKindOfClass:[CTRLBreakersViewController class]])
        return self;
    else if ([toVC isKindOfClass:[CTRLPanelsViewController class]] &&
             [fromVC isKindOfClass:[CTRLBreakersViewController class]])
        return self;
    else
        return nil;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return .5;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UICollectionViewController *fromVC = (UICollectionViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UICollectionViewController *toVC = (UICollectionViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    containerView.backgroundColor = toVC.view.backgroundColor;
    if ([toVC isKindOfClass:[CTRLBreakersViewController class]]) { //Zoom in
        [containerView insertSubview:toVC.view aboveSubview:fromVC.view];
        toVC.view.transform = CGAffineTransformMakeScale(.2, .2);
        toVC.view.frame = CGRectOffset(toVC.view.frame, 0, -60);
        toVC.view.backgroundColor = [UIColor clearColor];

        [UIView animateWithDuration:.3 animations:^{
            toVC.view.transform = CGAffineTransformIdentity;
            toVC.view.frame = CGRectOffset(toVC.view.frame, 0, 60);
            fromVC.view.transform = CGAffineTransformMakeScale(2.5, 2.5);
            fromVC.view.frame = CGRectOffset(fromVC.view.frame, 0, 50);
            fromVC.view.alpha = 0.0;
        } completion:^(BOOL finished) {
            [fromVC.view removeFromSuperview];
            fromVC.view.transform = CGAffineTransformIdentity;
            fromVC.view.alpha = 1.0;
            fromVC.view.backgroundColor = [UIColor defaultCollectionViewBackgroundColor];
            toVC.view.backgroundColor = [UIColor defaultCollectionViewBackgroundColor];
            [transitionContext completeTransition:YES];
        }];
    }
    else { //Zoom out
        toVC.view.alpha = 0.0;
        toVC.view.transform = CGAffineTransformMakeScale(3, 3);
        [containerView addSubview:toVC.view];
        [UIView animateWithDuration:.3 animations:^{
            toVC.view.alpha = 1.0;
            toVC.view.transform = CGAffineTransformIdentity;
            fromVC.view.transform = CGAffineTransformMakeScale(.2, .2);
        } completion:^(BOOL finished) {
            [fromVC.view removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
    }
}

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController
{
    NSManagedObjectContext *context = [CTRLDataStack sharedDataStack].mainContext;
    
    // If we have no MOC, persistence is currently offline.  No fetching.
    if (!context)
        return nil;
    
    // If our MOC changed, invalidate the fetchedResultsController so it gets recreated.
    if (context != _fetchedResultsController.managedObjectContext)
        _fetchedResultsController = nil;
    
    // If we have no fetchedResultsController, create one and perform a fetch to get the latest managed objects.
    if (!_fetchedResultsController) {
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        _fetchedResultsController.delegate = self;
        NSError *error;
        [_fetchedResultsController performFetch:&error];
    }
    
    return _fetchedResultsController;
}

- (void)rebuildDataSource
{
    self.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"house = %@", self.house];
    self.title = self.house.name;
    
    [self fetchPanels];
    [self.collectionView reloadData];
}

- (void)fetchPanels
{
    if (!self.fetchedResultsController)
        return;
    
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
}

- (void)storeWillChange:(NSNotification *)notif
{
    [self.fetchedResultsController.managedObjectContext performBlockAndWait:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController dismissViewControllerAnimated:NO completion:^{
                [self.navigationController popToRootViewControllerAnimated:NO];
            }];
        });
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *loadingView = [[UIView alloc] initWithFrame:self.collectionView.bounds];
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicatorView.center = loadingView.center;
        
        [loadingView addSubview:activityIndicatorView];
        self.collectionView.backgroundView = loadingView;
        [self.collectionView reloadData];
        
        self.navigationItem.leftBarButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
    });
}

- (void)storeDidChange:(NSNotification *)notif
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationItem.leftBarButtonItem.enabled = YES;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.collectionView.backgroundView = nil;
        
        [self.collectionView reloadData];
    });
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    if (self.isDragging) //Disregard changes while dragging
        return;
    
    [super controller:controller didChangeObject:anObject atIndexPath:indexPath
        forChangeType:type newIndexPath:newIndexPath];
    
    if (!self.insertedIndexPaths)
        self.insertedIndexPaths = @[];
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            self.insertedIndexPaths = [self.insertedIndexPaths arrayByAddingObject:newIndexPath];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [super controllerDidChangeContent:controller];
    
    self.pageControl.numberOfPages = self.fetchedResultsController.fetchedObjects.count;
    
    CGFloat pageWidth = self.collectionView.bounds.size.width;
    NSInteger pageNumber = floor((self.collectionView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = pageNumber;
    
    NSIndexPath *newIndexPath = self.insertedIndexPaths.firstObject;
    
    if (newIndexPath) {
        [self.collectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
    
    self.insertedIndexPaths = nil;
}

#pragma mark - CTRLPanelCollectionViewCellDelegate

- (void)panelCellDeleteButtonWasTapped:(CTRLPanelCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    self.pendingDeletePanel = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UIActionSheet *deleteActionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete this panel and all of the included breakers and fixtures? This cannot be undone."
                                                                   delegate:self
                                                          cancelButtonTitle:@"Absolutely Not"
                                                     destructiveButtonTitle:@"Delete Panel"
                                                          otherButtonTitles:nil];
    deleteActionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [deleteActionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        NSManagedObjectContext *moc = self.fetchedResultsController.managedObjectContext;
        [moc performBlockAndWait:^{
            [moc deleteObject:self.pendingDeletePanel];
            
            NSError *error;
            [moc save:&error];
        }];
    }
    
    self.pendingDeletePanel = nil;
}

@end
