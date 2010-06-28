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

#import <UIKit/UIKit.h>

@class EditableStringTable;

typedef enum
{
	kLeftSide,
	kRightSide
} SideTypes;

/*
 * Delegate for listening to edit events
 */
@protocol EditableStringTableDelegate <NSObject>

@optional

-(void)table:(EditableStringTable*)tableView rowAdded:(int)row;
-(void)table:(EditableStringTable*)tableView rowChanged:(int)row;
-(void)table:(EditableStringTable*)tableView rowDeleted:(int)row;
-(void)table:(EditableStringTable*)tableView rowMovedFrom:(int)fromRow to:(int)toRow;
-(void)table:(EditableStringTable*)tableView rowWasSelected:(int)row;
-(void)table:(EditableStringTable*)tableView rowWillDisplay:(int)row usingCellView:(UITableViewCell*)cellView;

@end

@interface EditableStringTable : UITableView <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
	NSString			*cellID;
	NSMutableArray		*cells;
	UITextField			*fieldBeingEdited;
	UIFont				*font;
	SideTypes			sideType;

	UIViewController	*navigationController;

	id <EditableStringTableDelegate>	tableDelegate;
	
	CGRect				saveFrame;
}

/*
 * Constructor
 */
-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style;

/*
 * Get/set the delegate
 */
-(void)setEditableStringTableDelegate:(id <EditableStringTableDelegate>)delegateArg;
-(id <EditableStringTableDelegate>)editableStringTableDelegate;

/*
 * Optional: set a view controller that the EditableStringTable will manage. 
 * The EditableStringTable will set/handle the Edit/Done button.
 */
-(void)setViewController:(UIViewController*)controller forSide:(SideTypes)side;

/*
 * Optional: Change the font used for table cells
 */
-(void)setFont:(UIFont*)font;

/*
 * Returns the cell values - an array of NSString objects
 */
-(NSArray*)getCells;

/*
 * Returns the number of cells
 */
-(int)count;

/*
 * Removes the item at the given row
 */
-(void)deleteItem:(int)row;

/*
 * Add a new cell
 */
-(void)addItem:(NSString*)value;

/*
 * Same as clicking the edit button
 */
-(void)editButton;

/*
 * Same as clicking the done button
 */
-(void)doneButton;

@end

