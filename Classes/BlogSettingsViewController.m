//
//  BlogSettingsViewController.m
//  WordPress
//
//  Created by Chris Boyd on 7/25/10.
//

#import "BlogSettingsViewController.h"

@implementation BlogSettingsViewController
@synthesize tableView, recentItems, actionSheet, isSaving, viewDidMove, keyboardIsVisible, buttonText;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	appDelegate = (WordPressAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	recentItems = [[NSArray alloc] initWithObjects:
				   @"10 Recent Items", 
				   @"25 Recent Items", 
				   @"50 Recent Items", 
				   @"100 Recent Items", 
				   nil];
	buttonText = @"Save";

	self.navigationItem.title = @"Settings";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) 
												 name:UIKeyboardWillShowNotification
											   object:self.view.window];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) 
												 name:UIKeyboardWillHideNotification
											   object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillHideNotification object:nil];
	[super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
	int result = 0;
	
	switch (section) {
		case 0:
			result = 3;
			break;
		case 1:
			result = 3;
			break;
		case 2:
			result = 1;
			break;
		default:
			break;
	}
	
	return result;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	// TODO: Double-check for performance drain later
    static NSString *normalCellIdentifier = @"Cell";
    static NSString *switchCellIdentifier = @"SwitchCell";
    static NSString *activityCellIdentifier = @"ActivityCell";
	static NSString *textCellIdentifier = @"TextCell";
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:normalCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:normalCellIdentifier] autorelease];
    }
	
	UITableViewActivityCell *activityCell = (UITableViewActivityCell *)[self.tableView dequeueReusableCellWithIdentifier:activityCellIdentifier];
	UITableViewSwitchCell *switchCell = (UITableViewSwitchCell *)[self.tableView dequeueReusableCellWithIdentifier:switchCellIdentifier];
	if(switchCell == nil) {
		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"UITableViewSwitchCell" owner:nil options:nil];
		for(id currentObject in topLevelObjects)
		{
			if([currentObject isKindOfClass:[UITableViewSwitchCell class]])
			{
				switchCell = (UITableViewSwitchCell *)currentObject;
				
				if(DeviceIsPad() == YES) {
					switchCell.cellSwitch.frame = CGRectMake(370, 8, 100, 50);
				}
				
				break;
			}
		}
	}
	
	if(activityCell == nil) {
		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"UITableViewActivityCell" owner:nil options:nil];
		for(id currentObject in topLevelObjects)
		{
			if([currentObject isKindOfClass:[UITableViewActivityCell class]])
			{
				activityCell = (UITableViewActivityCell *)currentObject;
				if(DeviceIsPad() == YES) {
					activityCell.textLabel.frame = CGRectMake(140, 5, 200, 40);
				}
				break;
			}
		}
	}
    
	switch (indexPath.section) {
		case 0:
			switch (indexPath.row) {
				case 0:
					switchCell.textLabel.text = @"Resize Photos";
					switchCell.cellSwitch.on = [[appDelegate.currentBlog objectForKey:kResizePhotoSetting] boolValue];
					
					cell = switchCell;
					cell.tag = 0;
					break;
				case 1:
					switchCell.textLabel.text = @"Geotagging";
					if([appDelegate.currentBlog objectForKey:kGeolocationSetting] != nil)
						switchCell.cellSwitch.on = [[appDelegate.currentBlog objectForKey:kGeolocationSetting] boolValue];
					else
						switchCell.cellSwitch.on = YES;
					cell = switchCell;
					cell.tag = 1;
					break;
				case 2:
					cell.textLabel.text = @"Recent Items";
					if([appDelegate.currentBlog valueForKey:kPostsDownloadCount] != nil)
						cell.detailTextLabel.text = [appDelegate.currentBlog valueForKey:kPostsDownloadCount];
					else {
						cell.detailTextLabel.text = [recentItems objectAtIndex:0];
					}
					cell.tag = 2;
					break;
				default:
					break;
			}
			break;
		case 1:
			cell.tag = 3;
			UITableViewCell *textCell = [tv dequeueReusableCellWithIdentifier:textCellIdentifier];
			if (textCell == nil) {
				textCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:textCellIdentifier] autorelease];
			}
			CGRect textFieldFrame = CGRectMake(110, 10, 185, 30);
			if(DeviceIsPad() == YES) {
				textFieldFrame = CGRectMake(200, 10, 300, 30);
			}
			UITextField *loginTextField = [[UITextField alloc] initWithFrame:textFieldFrame];
			loginTextField.adjustsFontSizeToFitWidth = YES;
			loginTextField.textColor = [UIColor blackColor];
			switch (indexPath.row) {
				case 0:
					switchCell.textLabel.text = @"Authentication";
					switchCell.cellSwitch.on = [[appDelegate.currentBlog objectForKey:@"authEnabled"] boolValue];
					cell = switchCell;
					cell.tag = 3;
					break;
				case 1:
					textCell.textLabel.text = @"Username";
					loginTextField.placeholder = @"HTTP Auth Username";
					loginTextField.keyboardType = UIKeyboardTypeEmailAddress;
					loginTextField.returnKeyType = UIReturnKeyDone;
					if([appDelegate.currentBlog objectForKey:@"authUsername"] != nil)
						loginTextField.text = [appDelegate.currentBlog objectForKey:@"authUsername"];
					else if([appDelegate.currentBlog objectForKey:@"username"] != nil)
						loginTextField.text = [appDelegate.currentBlog objectForKey:@"username"];
					textCell.tag = 4;
					
					if(DeviceIsPad() == YES)
						loginTextField.backgroundColor = [UIColor clearColor];
					else
						loginTextField.backgroundColor = [UIColor whiteColor];
					
					loginTextField.autocorrectionType = UITextAutocorrectionTypeNo;
					loginTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
					loginTextField.textAlignment = UITextAlignmentLeft;
					loginTextField.delegate = self;
					
					loginTextField.clearButtonMode = UITextFieldViewModeNever;
					[loginTextField setEnabled: YES];
					
					[textCell addSubview:loginTextField];
					[loginTextField release];
					cell = textCell;
					break;
				case 2:
					textCell.textLabel.text = @"Password";
					loginTextField.placeholder = @"HTTP Auth Password";
					loginTextField.keyboardType = UIKeyboardTypeDefault;
					loginTextField.returnKeyType = UIReturnKeyDone;
					loginTextField.secureTextEntry = YES;
					textCell.tag = 5;
					
					if(DeviceIsPad() == YES)
						loginTextField.backgroundColor = [UIColor clearColor];
					else
						loginTextField.backgroundColor = [UIColor whiteColor];
					
					loginTextField.autocorrectionType = UITextAutocorrectionTypeNo;
					loginTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
					loginTextField.textAlignment = UITextAlignmentLeft;
					loginTextField.delegate = self;
					
					loginTextField.clearButtonMode = UITextFieldViewModeNever;
					[loginTextField setEnabled: YES];
					
					[textCell addSubview:loginTextField];
					[loginTextField release];
					cell = textCell;
					break;
				default:
					break;           
			}
			break;
		case 2:
			if(isSaving)
				[activityCell.spinner startAnimating];
			else
				[activityCell.spinner stopAnimating];
			
			activityCell.textLabel.text = buttonText;
			cell = activityCell;
			cell.tag = 5;
			break;
		default:
			break;
	}
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *result = @"";
	
	switch (section) {
		case 1:
			result = @"HTTP";
			break;
		default:
			break;
	}
	
	return result;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
			switch (indexPath.row) {
				case 2:
					[self showPicker:self];
					break;
				default:
					break;
			}
			break;
		case 2:
			// Save Settings
			buttonText = @"Saving...";
			isSaving = YES;
			[self processRowValues];
			[self.tableView reloadData];
			[self.navigationController popViewControllerAnimated:YES];
			break;
		default:
			break;
	}
	[tv deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark UIPickerView delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {	
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
	return [recentItems count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [recentItems objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	[appDelegate.currentBlog setValue:[recentItems objectAtIndex:row] forKey:kPostsDownloadCount];
}

#pragma mark -
#pragma mark UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;	
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    activeTextField = nil;
}

#pragma mark -
#pragma mark Custom methods

- (IBAction)showPicker:(id)sender {
	[self processRowValues];
	actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	[actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
	
	CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
	UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
	pickerView.showsSelectionIndicator = YES;
	pickerView.delegate = self;
	pickerView.dataSource = self;
	[pickerView selectRow:[self selectedRecentItemsIndex] inComponent:0 animated:YES];
	[actionSheet addSubview:pickerView];
	
	UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Done"]];
	closeButton.momentary = YES; 
	closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
	closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
	closeButton.tintColor = [UIColor blackColor];
	[closeButton addTarget:self action:@selector(hidePicker:) forControlEvents:UIControlEventValueChanged];
	[actionSheet addSubview:closeButton];
	[closeButton release];
	
	[actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
	
	[actionSheet setBounds:CGRectMake(0, 0, 320, 485)];
}

- (IBAction)hidePicker:(id)sender {
	[actionSheet dismissWithClickedButtonIndex:0 animated:YES];
	[self.tableView reloadData];
}

- (int)selectedRecentItemsIndex {
	int result = 0;
	int index = 0;
	for(NSString *item in recentItems) {
		if([item isEqualToString:[appDelegate.currentBlog valueForKey:kPostsDownloadCount]]) {
			result = index;
			break;
		}
		index++;
	}
   return result;
}

- (void)processRowValues {
	NSInteger numSections = [self numberOfSectionsInTableView:self.tableView];
	for (NSInteger s = 0; s < numSections; s++) { 
		NSInteger numRowsInSection = [self tableView:self.tableView numberOfRowsInSection:s]; 
		for(NSInteger r = 0; r < numRowsInSection; r++) {
			UITableViewCell *cell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:r inSection:s]]; 
			for(UIView *subview in cell.contentView.subviews) {
				if([subview isKindOfClass:[UISwitch class]]) {
					UISwitch *cellSwitch = (UISwitch *)subview;
					switch (s) {
						case 0:
							switch (r) {
								case 0:
									[appDelegate.currentBlog setValue:[self transformedValue:cellSwitch.on] forKey:kResizePhotoSetting];
									break;
								case 1:
									[appDelegate.currentBlog setValue:[self transformedValue:cellSwitch.on] forKey:kGeolocationSetting];
									break;
								default:
									break;
							}
							break;
						case 1:
							switch (r) {
								case 0:
									if(cellSwitch.on)
										[appDelegate.currentBlog setValue:[NSNumber numberWithInt:1] forKey:@"authEnabled"];
									else
										[appDelegate.currentBlog setValue:[NSNumber numberWithInt:0] forKey:@"authEnabled"];
									break;
								default:
									break;
							}
							break;
						default:
							break;
					}
				}
				if([subview isKindOfClass:[UITextField class]]) {
					UITextField *cellText = (UITextField *)subview;
					switch (s) {
						case 1:
							switch (r) {
								case 1:
									[appDelegate.currentBlog setValue:cellText.text forKey:@"authUsername"];
									break;
								case 2:
									[appDelegate.currentBlog setValue:cellText.text forKey:@"authPassword"];
									break;
								default:
									break;
							}
							break;
						default:
							break;
					}
				}
			}
		} 
	}
}

- (NSString *)transformedValue:(BOOL)value {
    if(value)
		return @"YES";
	else
		return @"NO";
}

- (void)keyboardWillShow:(NSNotification *)notification {
    if (keyboardIsVisible)
        return;
	
	NSDictionary *info = [notification userInfo];
	NSValue *aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
	CGSize keyboardSize = [aValue CGRectValue].size;
	
	NSTimeInterval animationDuration = 0.300000011920929;
	CGRect frame = self.view.frame;
	frame.origin.y -= keyboardSize.height-35;
	frame.size.height += keyboardSize.height-35;
	[UIView beginAnimations:@"ResizeForKeyboard" context:nil];
	[UIView setAnimationDuration:animationDuration];
	self.view.frame = frame;
	[UIView commitAnimations];
	
	viewDidMove = YES;
    keyboardIsVisible = YES;
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    if (viewDidMove) {
        NSDictionary *info = [aNotification userInfo];
        NSValue *aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
        CGSize keyboardSize = [aValue CGRectValue].size;
		
        NSTimeInterval animationDuration = 0.300000011920929;
        CGRect frame = self.view.frame;
        frame.origin.y += keyboardSize.height-35;
        frame.size.height -= keyboardSize.height-35;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        self.view.frame = frame;
        [UIView commitAnimations];
		
        viewDidMove = NO;
    }
	
    keyboardIsVisible = NO;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (void)dealloc {
	[buttonText release];
	[actionSheet release];
	[tableView release];
	[recentItems release];
    [super dealloc];
}


@end
