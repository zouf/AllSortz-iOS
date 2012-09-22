//
//  ASAppDelegate.h
//  AllSortz
//
//  Created by Lawrence Velázquez on 7/18/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

@interface ASAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) IBOutlet UITabBarController *mainTabNavController;

@end
