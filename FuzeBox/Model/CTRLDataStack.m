//
//  CTRLDataStack.m
//  Breaker Buddy
//
//  Created by Hank Jacobs on 10/27/13.
//  Copyright (c) 2013 CTRL-Point. All rights reserved.
//

#import "CTRLDataStack.h"
#import "UbiquityStoreManager.h"

NSString *const CTRLDataStoreWillLoad = @"CTRLDataStoreWillLoad";
NSString *const CTRLDataStoreDidLoad = @"CTRLDataStoreDidLoad";

@interface CTRLDataStack ()<UbiquityStoreManagerDelegate>

@property (nonatomic, strong) UbiquityStoreManager *storeManager;
@property (nonatomic, strong) NSManagedObjectContext *saveContext; //Use for serializing to the disk

@end

@implementation CTRLDataStack
@synthesize mainContext = _mainContext;
@synthesize scratchContext = _scratchContext;
@synthesize useiCloud = _useiCloud;

+ (instancetype)sharedDataStack
{
    static dispatch_once_t onceToken;
    static CTRLDataStack *sharedDataStack;
    dispatch_once(&onceToken, ^{
        sharedDataStack = [[self alloc] init];
    });
    
    return sharedDataStack;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        self.storeManager = [[UbiquityStoreManager alloc] initWithDelegate:self];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - CoreData

- (void)setSaveContext:(NSManagedObjectContext *)saveContext
{
    if (_saveContext) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:_saveContext];
    }
     
    _saveContext = saveContext;
     
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveContextDidImportChanges:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:nil];
}

- (NSManagedObjectContext *)mainContext
{
     
    NSManagedObjectContext *currentSaveContext = self.saveContext;
    NSManagedObjectContext *currentMainContext = _mainContext;
     
    
    if (currentSaveContext == nil) {
        return nil;
    }

    if (currentMainContext == nil || currentMainContext.parentContext != currentSaveContext) {
        currentMainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        currentMainContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        currentMainContext.parentContext = self.saveContext;

        [[NSNotificationCenter defaultCenter] addObserver:self
               selector:@selector(mainContextDidSave:)
                   name:NSManagedObjectContextDidSaveNotification
                 object:currentMainContext];
        
         
        _mainContext = currentMainContext;
         
    }
    
    return _mainContext;
}

- (NSManagedObjectContext *)scratchContext
{
     
    NSManagedObjectContext *currentMainContext = self.mainContext;
    NSManagedObjectContext *currentScratchContext = _scratchContext;
     
    
    if (currentMainContext == nil)
        return nil;
    
    if (currentScratchContext == nil || currentScratchContext.parentContext != currentMainContext) {
        currentScratchContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        currentScratchContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        currentScratchContext.parentContext = self.mainContext;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(scratchContextDidSave:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:currentScratchContext];
        
         
        _scratchContext = currentScratchContext;
         
    }
    
    return _scratchContext;
}

- (NSURL *)modelURL
{
    return [[NSBundle mainBundle] URLForResource:[self modelName] withExtension:@"momd"];
}

- (NSString *)storeFilename
{
    return [[self modelName] stringByAppendingPathExtension:@"sqlite"];
}

- (NSURL *)storeURL
{
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[self storeFilename]];
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)modelName
{
    return @"BreakerBuddy";
}

#pragma mark - iCloud

- (void)setUseiCloud:(BOOL)useiCloud
{
    self.storeManager.cloudEnabled = useiCloud;
}


- (void)setUseiCloudAndReplace:(BOOL)useiCloud
{
    if (useiCloud) {
        [self.storeManager setCloudEnabledAndOverwriteCloudWithLocalIfConfirmed:^(void(^setConfirmationAnswer)(BOOL answer)){
            setConfirmationAnswer(YES);
        }];
    }
    else {
        [self.storeManager setCloudDisabledAndOverwriteLocalWithCloudIfConfirmed:^(void(^setConfirmationAnswer)(BOOL answer)){
            setConfirmationAnswer(YES);
        }];
    }
}

- (BOOL)useiCloud
{
    return self.storeManager.cloudEnabled;
}

- (BOOL)cloudAvailable
{
    return self.storeManager.cloudAvailable;
}

- (NSString *)cloudStoreName
{
    return @"iCloudStore";
}

#pragma mark - NSManagedObjectContext Notifications

- (void)saveContextDidImportChanges:(NSNotification *)notif
{
    [self.mainContext performBlock:^{
        [self.mainContext mergeChangesFromContextDidSaveNotification:notif];
    }];
}

- (void)mainContextDidSave:(NSNotification *)notif
{
    [self.saveContext performBlockAndWait:^{
        NSError *error;
        [self.saveContext save:&error];
    }];
}

- (void)scratchContextDidSave:(NSNotification *)notif
{
    [self.mainContext performBlockAndWait:^{
        NSError *error;
        [self.mainContext save:&error];
    }];
}

#pragma mark - UbiquityStoreManagerDelegate

- (void)ubiquityStoreManager:(UbiquityStoreManager *)manager willLoadStoreIsCloud:(BOOL)isCloudStore
{
     
    self.saveContext = nil;
//    self.storeManager.migrationStrategy = UbiquityStoreMigrationStrategyCopyEntities;
    
}

//- (void)ubiquityStoreManagerHandleCloudContentDeletion:(UbiquityStoreManager *)manager
//{
//    [manager migrateCloudToLocal];
//}

- (void)ubiquityStoreManager:(UbiquityStoreManager *)manager didLoadStoreForCoordinator:(NSPersistentStoreCoordinator *)coordinator isCloud:(BOOL)isCloudStore
{
    
    self.saveContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [self.saveContext setPersistentStoreCoordinator:coordinator];
    [self.saveContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    [self.mainContext performBlock:^{}]; //recreate main context
     
}

- (NSManagedObjectContext *)ubiquityStoreManager:(UbiquityStoreManager *)manager managedObjectContextForUbiquityChanges:(NSNotification *)note
{
    return self.saveContext;
}

- (BOOL)ubiquityStoreManager:(UbiquityStoreManager *)manager shouldMigrateFromStoreURL:(NSURL *)migrationStoreURL toStoreURL:(NSURL *)destinationStoreURL isCloud:(BOOL)isCloudStore
{
    return YES;
}

- (BOOL)ubiquityStoreManager:(UbiquityStoreManager *)manager handleCloudContentCorruptionWithHealthyStore:(BOOL)storeHealthy
{
    return NO;
}


- (void)ubiquityStoreManager:(UbiquityStoreManager *)manager log:(NSString *)message
{

    NSLog(@"%@", message);

}

#pragma mark - DESTORY EVERYTHING

- (void)destroyEverything
{
    NSDictionary *options =  @{ NSPersistentStoreUbiquitousContentNameKey :  [self cloudStoreName],
                                NSMigratePersistentStoresAutomaticallyOption : @YES,
                                NSInferMappingModelAutomaticallyOption : @YES };
    NSError *error;
    [NSPersistentStoreCoordinator removeUbiquitousContentAndPersistentStoreAtURL:[self storeURL] options:options error:&error];
    
    if (error) {
        NSLog(@"%@", error);
    }
    else {
        _mainContext = nil;
        _scratchContext = nil;
        _saveContext = nil;
    }
}

@end
