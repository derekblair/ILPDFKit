

#import "PDFObject.h"
#import "PDFUtility.h"
#import "PDFDictionary.h"
#import "PDFArray.h"
#import "PDFDocument.h"

@implementation PDFObject

-(void)dealloc
{
    [representation release];
    [super dealloc];
}

-(NSString*)pdfFileRepresentation
{
    return representation;
}



+(PDFObject*)createWithPDFRepresentation:(NSString*)rep 
{
    NSString* test = [rep stringByTrimmingCharactersInSet:[PDFUtility whiteSpaceCharacterSet]];
    if(test.length>=2)
    {
        if([test characterAtIndex:0] == '<' && [test characterAtIndex:1] == '<')
            return [[PDFDictionary alloc] initWithPDFRepresentation:rep ];
        if([test characterAtIndex:0] == '[')
            return [[PDFArray alloc] initWithPDFRepresentation:rep ];
    }
    
    return [[PDFObject alloc] initWithPDFRepresentation:rep ];
}


-(id)initWithPDFRepresentation:(NSString*)rep 
{
    self = [super init];
    if(self != nil)
    {
       
        NSString* temp = [rep stringByTrimmingCharactersInSet:[PDFUtility whiteSpaceCharacterSet]];
        
        representation = [temp retain];
      
    }
    
    return self;
}


-(id)initWithPDFObject:(CGPDFObjectRef)obj
{
    self = [super init];
    if(self != nil)
    {
    }
    return self;
}




-(void)dereferenceWithDocument:(PDFDocument*)document
{
    representation = [[document codeForObjectWithNumber:_objectNumber GenerationNumber:_generationNumber] retain];
}



@end
