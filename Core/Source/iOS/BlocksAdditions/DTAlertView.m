//
//  DTAlertView.m
//  DTFoundation
//
//  Created by Oliver Drobnik on 11/22/12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import "DTAlertView.h"
#import "DTWeakSupport.h"

@interface DTAlertView() <UIAlertViewDelegate>

@end

@implementation DTAlertView
{
	DT_WEAK_VARIABLE id <UIAlertViewDelegate> _externalDelegate;

	NSMutableDictionary *_actionsPerIndex;

	DTAlertViewBlock _cancelBlock;

	BOOL _isDeallocating;
}


// overwrite standard initializer so that we can set our own delegate
- (void)dealloc
{
	_isDeallocating = YES;
}

- (id)init
{
    return [self initWithTitle:nil message:nil];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message
{
    return [self initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
}

// designated initializer
- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
	self = [super initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
	if (self)
	{
        if (otherButtonTitles != nil) {
            [self addButtonWithTitle:otherButtonTitles];
            va_list args;
            va_start(args, otherButtonTitles);
            NSString *title = nil;
            while( (title = va_arg(args, NSString *)) ) {
                [self addButtonWithTitle:title];
            }
            va_end(args);
        }

		_actionsPerIndex = [[NSMutableDictionary alloc] init];
		self.delegate = self;
        _externalDelegate = delegate;
	}
	return self;
}

- (NSInteger)addButtonWithTitle:(NSString *)title block:(DTAlertViewBlock)block
{
	NSInteger retIndex = [self addButtonWithTitle:title];

	if (block)
	{
		NSNumber *key = [NSNumber numberWithInteger:retIndex];
		[_actionsPerIndex setObject:[block copy] forKey:key];
	}

	return retIndex;
}

- (NSInteger)addCancelButtonWithTitle:(NSString *)title block:(DTAlertViewBlock)block
{
	NSInteger retIndex = [self addButtonWithTitle:title block:block];
	[self setCancelButtonIndex:retIndex];

	return retIndex;
}

- (void)setCancelBlock:(DTAlertViewBlock)block
{
	_cancelBlock = block;
}

# pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSNumber *key = [NSNumber numberWithInteger:buttonIndex];
    
	DTAlertViewBlock block = [_actionsPerIndex objectForKey:key];
	if (block)
	{
		block();
	}

	if ([_externalDelegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
	{
		[_externalDelegate alertView:self clickedButtonAtIndex:buttonIndex];
	}
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
	if (_cancelBlock)
	{
		_cancelBlock();
	}

	if ([_externalDelegate respondsToSelector:@selector(alertViewCancel:)])
	{
		[_externalDelegate alertViewCancel:self];
	}
}

- (void)willPresentAlertView:(UIAlertView *)alertView
{
	if ([_externalDelegate respondsToSelector:@selector(willPresentAlertView:)])
	{
		[_externalDelegate willPresentAlertView:self];
	}
}

- (void)didPresentAlertView:(UIAlertView *)alertView
{
	if ([_externalDelegate respondsToSelector:@selector(didPresentAlertView:)])
	{
		[_externalDelegate didPresentAlertView:self];
	}
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if ([_externalDelegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)])
	{
		[_externalDelegate alertView:self willDismissWithButtonIndex:buttonIndex];
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if ([_externalDelegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)])
	{
		[_externalDelegate alertView:self didDismissWithButtonIndex:buttonIndex];
	}
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
	if ([_externalDelegate respondsToSelector:@selector(alertViewShouldEnableFirstOtherButton:)])
	{
		return [_externalDelegate alertViewShouldEnableFirstOtherButton:self];
	}

	return YES;
}

#pragma mark - Properties

- (id <UIAlertViewDelegate>)delegate
{
	return _externalDelegate;
}

- (void)setDelegate:(id <UIAlertViewDelegate>)delegate
{
	if (delegate == self)
	{
		[super setDelegate:self];
	}
	else if (delegate == nil)
	{
		// UIAlertView dealloc sets delegate to nil
		if (_isDeallocating)
		{
			[super setDelegate:nil];
		}
		else
		{
			[super setDelegate:self];
			_externalDelegate = nil;
		}
	}
	else
	{
		_externalDelegate = delegate;
	}
}


@end
