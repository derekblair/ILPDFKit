//  Created by Derek Blair on 2/24/2014.
//  Copyright (c) 2014 iwelabs. All rights reserved.

#import "PDFFormAction.h"
#import "PDFForm.h"
#import "PDFFormContainer.h"
#import "PDFDictionary.h"
#import "PDFStream.h"

@implementation PDFFormAction



#pragma mark - NSObject

-(void)dealloc
{
    self.string = nil;
    self.prefix = nil;
    self.key = nil;
}


// Only Javascript Actions are Supported


#pragma mark - Initialization

-(id)initWithActionDictionary:(PDFDictionary*)dict
{
    self = [super init];
    if(self != nil)
    {
        NSString* actionType = [dict objectForKey:@"S"];
        
        if([actionType isEqualToString:@"JavaScript"])
        {
            id js = [dict objectForKey:@"JS"];
            if([js isKindOfClass:[NSString class]])
            {
                self.string = js;
            }
            else if([js isKindOfClass:[PDFStream class]])
            {
                NSString* temp = [[NSString alloc] initWithData:[js data] encoding:NSASCIIStringEncoding];
                self.string = temp;
            }
        }
    }
    
    return self;
}

#pragma mark - Script Execution

-(void)execute
{
    NSString* exec = _string;
    if(_prefix)exec = [_prefix stringByAppendingFormat:@"\n\n%@;",exec];
    [(self.parent.parent) executeScript:exec];
}



@end
