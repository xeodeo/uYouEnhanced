#import "AppIconOptionsController.h"
#import <YouTubeHeader/YTAssetLoader.h>

@interface AppIconOptionsController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray<NSString *> *appIcons;
@property (assign, nonatomic) NSInteger selectedIconIndex;

@end

@implementation AppIconOptionsController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Change App Icon";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"YTSans-Bold" size:22], NSForegroundColorAttributeName: [UIColor whiteColor]}];

    self.selectedIconIndex = -1;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];

    self.appIcons = @[@"White", @"YTLitePlus", @"Blue", @"Outline", @"2012", @"2013", @"2007", @"Black", @"Oreo", @"uYou", @"2012_Cyan", @"uYouPlus"];

    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    NSBundle *backIcon = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"uYouPlus" ofType:@"bundle"]];
    UIImage *backImage = [UIImage imageNamed:@"Back.png" inBundle:backIcon compatibleWithTraitCollection:nil];
    backImage = [self resizeImage:backImage newSize:CGSizeMake(24, 24)];
    backImage = [backImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.backButton setTintColor:[UIColor whiteColor]];
    [self.backButton setImage:backImage forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.backButton setFrame:CGRectMake(0, 0, 24, 24)];
    UIBarButtonItem *customBackButton = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
    self.navigationItem.leftBarButtonItem = customBackButton;

    UIColor *buttonColor = [UIColor colorWithRed:203.0/255.0 green:22.0/255.0 blue:51.0/255.0 alpha:1.0];
    UIImage *resetImage = [UIImage systemImageNamed:@"arrow.clockwise.circle.fill"];
    UIBarButtonItem *resetButton = [[UIBarButtonItem alloc] initWithImage:resetImage style:UIBarButtonItemStylePlain target:self action:@selector(resetIcon)];
    resetButton.tintColor = buttonColor;
    
    UIImage *saveImage = [UIImage systemImageNamed:@"square.and.arrow.up.fill"];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithImage:saveImage style:UIBarButtonItemStylePlain target:self action:@selector(saveIcon)];
    saveButton.tintColor = buttonColor;

    self.navigationItem.rightBarButtonItems = @[saveButton, resetButton];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"uYouPlus" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    self.appIcons = [bundle pathsForResourcesOfType:@"png" inDirectory:@"AppIcons"];
    
    if (![UIApplication sharedApplication].supportsAlternateIcons) {
        NSLog(@"Alternate icons are not supported on this device.");
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.appIcons.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    NSString *iconName = self.appIcons[indexPath.row];
    cell.textLabel.text = iconName;

    UIImage *iconImage = [UIImage imageNamed:iconName];
    cell.imageView.image = [self createRoundedImage:iconImage size:CGSizeMake(40, 40)];

    if (indexPath.row == self.selectedIconIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedIconIndex = indexPath.row;
    [self.tableView reloadData];
}

- (void)resetIcon {
    [[UIApplication sharedApplication] setAlternateIconName:nil completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error resetting icon: %@", error.localizedDescription);
            [self showAlertWithTitle:@"Error" message:@"Failed to reset icon"];
        } else {
            NSLog(@"Icon reset successfully");
            [self showAlertWithTitle:@"Success" message:@"Icon reset successfully"];
            [self.tableView reloadData];
        }
    }];
}

- (void)saveIcon {
    if (![UIApplication sharedApplication].supportsAlternateIcons) {
        NSLog(@"Alternate icons are not supported on this device.");
        return;
    }

    NSString *iconName = self.appIcons[self.selectedIconIndex];
    NSString *iconPath = [[NSBundle mainBundle] pathForResource:iconName ofType:@"png"];
    
    UIImage *iconImage = [UIImage imageNamed:iconName];
    UIImage *roundedIconImage = [self createRoundedImage:iconImage size:CGSizeMake(120, 120)]; // Adjust size as needed
    
    // Save the image to the main app bundle
    NSData *imageData = UIImagePNGRepresentation(roundedIconImage);
    NSString *newIconPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_custom", iconName] ofType:@"png"];
    [imageData writeToFile:newIconPath atomically:YES];

    [[UIApplication sharedApplication] setAlternateIconName:[NSString stringWithFormat:@"%@_custom", iconName] completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error setting alternate icon: %@", error.localizedDescription);
            [self showAlertWithTitle:@"Error" message:@"Failed to set alternate icon"];
        } else {
            NSLog(@"Alternate icon set successfully");
            [self showAlertWithTitle:@"Success" message:@"Alternate icon set successfully"];
            [self.tableView reloadData];
        }
    }];
}

- (UIImage *)createRoundedImage:(UIImage *)image size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height) cornerRadius:size.width * 0.1]; // Adjust the corner radius as needed
    [path addClip];
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return roundedImage;
}

- (UIImage *)resizeImage:(UIImage *)image newSize:(CGSize)newSize { // Back Button
    UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
 }

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
