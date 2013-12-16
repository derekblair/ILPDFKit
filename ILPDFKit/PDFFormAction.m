

#import "PDFFormAction.h"
#import "PDFForm.h"
#import "PDFFormContainer.h"
#import "PDFDictionary.h"
#import "PDFStream.h"

@implementation PDFFormAction


// Only Javascript Actions are Supported

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
                [temp release];
            }
        }
    }
    
    return self;
}


-(void)execute
{
    NSString* exec = _string;
    if(_prefix)exec = [_prefix stringByAppendingFormat:@"\n\n%@;",exec];
    [self.parent.parent executeJS:exec];
}

-(void)dealloc
{
    self.string = nil;
    self.prefix = nil;
    self.key = nil;
    [super dealloc];
}

@end
