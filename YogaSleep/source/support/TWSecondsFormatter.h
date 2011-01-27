//
//  TWSecondsFormatter.h
//
//  Copyright 2009 Trollwerks Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TWSecondsFormatter : NSFormatter
{
}

- (NSString *)stringForObjectValue:(id)object;
- (BOOL) getObjectValue:(id *)object forString:(NSString *)string errorDescription:(NSString  **)error;

// no NSAttributedString on iPhone!
#if !TARGET_OS_IPHONE
- (NSAttributedString *) attributedStringForObjectValue:(id)object withDefaultAttributes:(NSDictionary *)attributes;
#endif !TARGET_OS_IPHONE

@end
