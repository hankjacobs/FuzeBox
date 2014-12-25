//
//  CTRLGenericSelectionListViewController.h
//  FuzeBox
//
//  Created by Hank Jacobs on 12/14/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CTRLGenericSelectionDelegate;
@interface CTRLGenericSelectionListViewController : UITableViewController

@property (nonatomic, readonly) NSManagedObjectContext *moc;
@property (nonatomic, readonly) NSFetchRequest *fetchRequest;
@property (nonatomic, readonly) NSString *sectionNameKeypath;
@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSString *displayKeyPath;
@property (nonatomic, weak) id<CTRLGenericSelectionDelegate> delegate;
@property (nonatomic, strong) id selectedObject;

- (id)initWithStyle:(UITableViewStyle)style fetchRequest:(NSFetchRequest *)fetchRequest sectionNameKeyPath:(NSString *)sectionNameKeyPath managedObjectContext:(NSManagedObjectContext *)moc;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@protocol CTRLGenericSelectionDelegate <NSObject>

- (void)genericSelectionController:(CTRLGenericSelectionListViewController *)controller didSelectObject:(id)object;

@end