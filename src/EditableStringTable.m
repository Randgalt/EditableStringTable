/*
 * Copyright 2010 Jordan Zimmerman
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "EditableStringTable.h"

@interface EditableTableCell : UITableViewCell
{
	UITextField		*textField;
}

-(UITextField*)textField;
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)str parent:(EditableStringTable*)parent;

@end

@implementation EditableTableCell

#define MARGIN 10
#define FONT_MARGIN 20
#define ACCESSORY_WIDTH 60

-(UITextField*)textField
{
	return textField;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)str parent:(EditableStringTable*)parent
{
	if ( (self = [super initWithStyle:style reuseIdentifier:str]) != nil )
	{
		textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
		textField.frame = CGRectMake(MARGIN / 2, MARGIN / 2, self.contentView.frame.size.width - MARGIN - ACCESSORY_WIDTH, self.contentView.frame.size.height - MARGIN);
		textField.font = [UIFont boldSystemFontOfSize:self.contentView.frame.size.height - FONT_MARGIN];
		textField.enabled = NO;	
		textField.returnKeyType = UIReturnKeyDone;
		textField.delegate = parent;
		
		[self.contentView addSubview:textField];
	}
	return self;
}

-(void)dealloc
{
	[textField release];
	[super dealloc];
}

@end

@implementation EditableStringTable

-(void)setEditButton
{
	UIBarButtonItem		*editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButton)];
	if ( sideType == kLeftSide )
	{
		navigationController.navigationItem.leftBarButtonItem = editButton;
	}
	else 
	{
		navigationController.navigationItem.rightBarButtonItem = editButton;
	}

	[editButton release];
}

-(void)setDoneButton
{
	UIBarButtonItem		*doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButton)];
	if ( sideType == kLeftSide )
	{
		navigationController.navigationItem.leftBarButtonItem = doneButton;
	}
	else 
	{
		navigationController.navigationItem.rightBarButtonItem = doneButton;
	}
	[doneButton release];
}

-(void)editButton
{
	[self setEditing:YES animated:YES];
	[self setDoneButton];
}

-(void)doneButton
{
	[fieldBeingEdited resignFirstResponder];
	[self setEditing:NO animated:YES];
	[self setEditButton];
}

-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
	if ( (self = [super initWithFrame:frame style:style]) != nil )
	{
		[self awakeFromNib];
	}
	return self;
}

-(EditableTableCell*)cellForText:(UITextField*)text
{
	for ( EditableTableCell *cell in [self visibleCells] )
	{
		if ( [cell textField] == text )
		{
			return cell;
		}
	}
	return nil;
}

-(NSIndexPath *)indexPathForText:(UITextField*)text
{
	EditableTableCell	*cell = [self cellForText:text];
	return (cell != nil) ? [self indexPathForCell:cell] : nil;
}

-(void)keyboardDidShow:(NSNotification*)notification
{
	if ( self.editing )
	{	
		NSIndexPath		*indexPath = [self indexPathForText:fieldBeingEdited];
		CGRect			cellRect = [self rectForRowAtIndexPath:indexPath];

		CGRect			keyboardRect;
		[[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardRect];
		keyboardRect = [self convertRect:keyboardRect fromView:nil];
		
		CGRect			frame = self.frame;
		saveFrame = frame;
		
		frame.size.height = keyboardRect.origin.y - frame.origin.y;
		self.frame = frame;
		
		[self scrollRectToVisible:cellRect animated:YES];
	}
}

-(void)keyboardWillHide
{
	if ( self.editing )
	{	
		[UIView beginAnimations:nil context:nil];
		self.frame = saveFrame;
		[UIView commitAnimations];
	}
}

-(void)setFont:(UIFont*)fontArg
{
	[font release];
	font = [fontArg retain];
}

-(void)awakeFromNib
{
	self.delegate = self;
	self.dataSource = self;
	tableDelegate = nil;
	fieldBeingEdited = nil;
	navigationController = nil;
	font = nil;
	
	cellID = [[NSString stringWithFormat:@"%@", self] retain];
	cells = [[NSMutableArray alloc] init];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

-(void)dealloc
{
	[tableDelegate release];
	[cellID release];
	[cells release];
	[fieldBeingEdited release];
	[navigationController release];
	[font release];
	[super dealloc];
}

-(void)deleteItem:(int)row
{
	[cells removeObjectAtIndex:row];
	[self reloadData];
	if ( [tableDelegate respondsToSelector: @selector(table:rowDeleted:)] ) 
	{
		[tableDelegate table:self rowDeleted:row];
	}
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self deleteItem:indexPath.row];
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	[cells exchangeObjectAtIndex:toIndexPath.row withObjectAtIndex:fromIndexPath.row];
	if ( [tableDelegate respondsToSelector: @selector(table:rowMovedFrom:to:)] ) 
	{
		[tableDelegate table:self rowMovedFrom:fromIndexPath.row to:toIndexPath.row];
	}
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];	 
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
	if ( [tableDelegate respondsToSelector: @selector(table:rowWasSelected:)] ) 
	{
		[tableDelegate table:self rowWasSelected:indexPath.row];
	}
}

-(UITableViewCell*)tableView:(UITableView *)tableViewArg cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	EditableTableCell *cell = (EditableTableCell*)[self dequeueReusableCellWithIdentifier:cellID];
    if ( cell == nil)
	{
        cell = [[[EditableTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID parent:self] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
	[cell textField].text = [cells objectAtIndex:indexPath.row];
	[cell textField].textColor = (([self indexPathForSelectedRow] != nil) && ([self indexPathForSelectedRow].row == indexPath.row)) ? [UIColor whiteColor] : [UIColor blackColor];
	
	if ( [tableDelegate respondsToSelector: @selector(table:rowWillDisplay:usingCellView:)] ) 
	{
		[tableDelegate table:self rowWillDisplay:indexPath.row usingCellView:cell];
	}

	return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [cells count];
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animate
{
	[super setEditing:editing animated:animate];
	for ( EditableTableCell *view in [self visibleCells] )
	{
		[view textField].textColor = [UIColor blackColor];
		[view textField].enabled = editing;
	}
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

-(int)indexForText:(UITextField*)text
{
	int	index = 0;
	for ( EditableTableCell *cell in [self visibleCells] )
	{
		if ( [cell textField] == text )
		{
			break;
		}
		++index;
	}
	return index;
}

-(void)releaseEditingField
{
	[fieldBeingEdited release];
	fieldBeingEdited = nil;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
	[self releaseEditingField];
	fieldBeingEdited = [textField retain];
	
	UITableViewCell *cell = (UITableViewCell*) [[textField superview] superview];
    [self scrollToRowAtIndexPath:[self indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{	
	[self releaseEditingField];
	[cells replaceObjectAtIndex:[self indexPathForText:textField].row withObject:textField.text];
	if ( [tableDelegate respondsToSelector: @selector(table:rowChanged:)] ) 
	{
		[tableDelegate table:self rowChanged:[self indexForText:textField]];
	}
}

-(void)addItem:(NSString*)value
{
	[cells addObject:value];
	[self reloadData];
	if ( [tableDelegate respondsToSelector: @selector(table:rowAdded:)] ) 
	{
		[tableDelegate table:self rowAdded:([cells count] - 1)];
	}
}

-(id <EditableStringTableDelegate>)editableStringTableDelegate
{
	return tableDelegate;
}

-(void)setEditableStringTableDelegate:(id <EditableStringTableDelegate>)delegateArg
{
	[tableDelegate release];
	tableDelegate = [delegateArg retain];
}

-(NSArray*)getCells
{
	return [NSArray arrayWithArray:cells];
}

-(void)setViewController:(UIViewController*)controller forSide:(SideTypes)side
{
	[navigationController release];
	navigationController = [controller retain];
	sideType = side;
	
	[self setEditButton];
}

-(int)count
{
	return [cells count];
}

@end
