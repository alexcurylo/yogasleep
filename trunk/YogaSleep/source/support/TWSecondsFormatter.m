//
//  TWSecondsFormatter.h
//
//  Copyright 2009 Trollwerks Inc. All rights reserved.
//

#import "TWSecondsFormatter.h"

@implementation TWSecondsFormatter

- (NSString *)stringForObjectValue:(id)object
{
   NSString *result = nil;
   unsigned value;
   unsigned days = 0;
   unsigned hours = 0;
   unsigned minutes = 0;
   unsigned seconds = 0;

   if(nil == object || NO == [object isKindOfClass:[NSNumber class]] || isnan([object doubleValue])) {
          return nil;
   }

   double doubleValue = [object doubleValue];
   BOOL isNegative = 0 > doubleValue;
   if (isNegative)
      doubleValue *= -1.;

   value = (unsigned)doubleValue;

   seconds         = value % 60;
   minutes         = value / 60;

   while(60 <= minutes)
   {
          minutes -= 60;
          ++hours;
   }

   while(24 <= hours)
   {
          hours -= 24;
          ++days;
   }

   if(0 < days) {
          result = [NSString stringWithFormat:@"%u:%.2u:%.2u:%.2u", days, hours, minutes, seconds];
   }
   else if(0 < hours) {
          result = [NSString stringWithFormat:@"%u:%.2u:%.2u", hours, minutes, seconds];
   }
   else if(0 < minutes) {
          result = [NSString stringWithFormat:@"%u:%.2u", minutes, seconds];
   }
   else {
          result = [NSString stringWithFormat:@"0:%.2u", seconds];
   }

   if (isNegative)
      result = [@"-" stringByAppendingString:result];

   return result;
}

- (BOOL) getObjectValue:(id *)object forString:(NSString *)string errorDescription:(NSString  **)error
{
        NSScanner *scanner = nil;
        BOOL result = NO;
        int value = 0;
        unsigned seconds = 0;

        scanner = [NSScanner scannerWithString:string];
       
        while(NO == [scanner isAtEnd]) {
               
                // Grab a value
                if([scanner scanInt:&value]) {
                        seconds         *= 60;
                        seconds         += value;
                        result          = YES;
                }
               
                // Grab the separator, if present
                [scanner scanString:@":" intoString:NULL];
        }
       
        if(result && NULL != object) {
                *object = [NSNumber numberWithUnsignedInt:seconds];
        }
        else if(NULL != error) {
                *error = @"Couldn't convert value to seconds";
        }
       
        return result;
}

// no NSAttributedString on iPhone!
#if !TARGET_OS_IPHONE
- (NSAttributedString *) attributedStringForObjectValue:(id)object withDefaultAttributes:(NSDictionary *)attributes
{
        NSAttributedString              *result         = nil;
       
        result = [[NSAttributedString alloc] initWithString:[self stringForObjectValue:object] attributes:attributes];
        return [result autorelease];
}
#endif //!TARGET_OS_IPHONE

@end
