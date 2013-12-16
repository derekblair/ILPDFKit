

#import "PDFObject.h"
#import "PDFUtility.h"
#import "PDFDictionary.h"
#import "PDFArray.h"
#import "PDFDocument.h"

@implementation PDFObject
{
    NSString* _representation;
}


-(void)dealloc
{
    [_representation release];
    [super dealloc];
}

-(NSString*)pdfFileRepresentation
{
    return _representation;
}

#pragma mark - Object Creation

+(PDFObject*)createWithPDFRepresentation:(NSString*)rep Document:(PDFDocument*)parentDocument
{
    NSString* test = [rep stringByTrimmingCharactersInSet:[PDFUtility whiteSpaceCharacterSet]];
    if(test.length>=2)
    {
        if([test characterAtIndex:0] == '<' && [test characterAtIndex:1] == '<')
            return [[PDFDictionary alloc] initWithPDFRepresentation:rep Document:parentDocument];
        if([test characterAtIndex:0] == '[')
            return [[PDFArray alloc] initWithPDFRepresentation:rep Document:parentDocument];
    }
    
    return [[PDFObject alloc] initWithPDFRepresentation:rep Document:parentDocument];
}


-(id)initWithPDFRepresentation:(NSString*)rep Document:(PDFDocument*)parentDocument
{
    self = [super init];
    if(self != nil)
    {
       
        NSString* temp = [rep stringByTrimmingCharactersInSet:[PDFUtility whiteSpaceCharacterSet]];
        _representation = [temp retain];
        _parentDocument = parentDocument;
      
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


-(id)initWithObjectNumber:(NSUInteger)objNumber GenerationNumber:(NSUInteger)genNumber Document:(PDFDocument*)parentDocument
{
    
    _objectNumber = objNumber;
    _generationNumber = genNumber;
    return [self initWithPDFRepresentation:[parentDocument codeForObjectWithNumber:_objectNumber GenerationNumber:_generationNumber] Document:parentDocument];
}



@end
