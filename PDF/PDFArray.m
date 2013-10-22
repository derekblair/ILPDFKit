
#import "PDFArray.h"
#import "PDFDictionary.h"
#import "PDFStream.h"
#import "PDFUtility.h"
#import "PDFDocument.h"
#import "PDFObjectParser.h"

@interface PDFArray()
    -(PDFStream*)streamAtIndex:(NSUInteger)index;
    -(PDFDictionary*)dictionaryAtIndex:(NSUInteger)index;
    -(PDFArray*)arrayAtIndex:(NSUInteger)index;
    -(NSString*)stringAtIndex:(NSUInteger)indexy;
    -(NSString*)nameAtIndex:(NSUInteger)index;
    -(NSNumber*)integerAtIndex:(NSUInteger)index;
    -(NSNumber*)realAtIndex:(NSUInteger)index;
    -(NSNumber*)booleanAtIndex:(NSUInteger)index;
    -(id)pdfObjectAtIndex:(NSUInteger)index;
@end

@implementation PDFArray
@synthesize nsa;
@synthesize arr;

-(void)dealloc
{
    [nsa release];
    [super dealloc];
}

-(id)initWithArray:(CGPDFArrayRef)parr
{
    self = [super init];
    
    if(self != nil)
    {
        arr = parr;
    }
    
    return self;
}

-(CGPDFObjectType)typeAtIndex:(NSUInteger)aIndex
{
    CGPDFObjectRef obj = NULL;
    if(CGPDFArrayGetObject(arr, aIndex, &obj))
    {
        return CGPDFObjectGetType(obj);
    }
    
    return kCGPDFObjectTypeNull;
}

-(CGRect)rect
{
    if([self.nsa count] < 4)return CGRectZero;
    CGFloat x0,y0,x1,y1;
    x0 = [[self.nsa objectAtIndex:0] floatValue];
    y0 = [[self.nsa objectAtIndex:1] floatValue];
    x1 = [[self.nsa objectAtIndex:2] floatValue];
    y1 = [[self.nsa objectAtIndex:3] floatValue];
    return CGRectMake(MIN(x0,x1),MIN(y0,y1),fabsf(x1-x0),fabsf(y1-y0));
}

-(id)objectAtIndex:(NSUInteger)aIndex
{
    if(aIndex < [self.nsa count])return [self.nsa objectAtIndex:aIndex];
    return nil;
}

-(NSUInteger)count
{
    return [self.nsa count];
}

-(id)firstObject
{
    if([self count]>0)return [self.nsa objectAtIndex:0];
    return nil;
}

-(id)lastObject
{
    return [self.nsa lastObject];
}

-(BOOL)isEqualToArray:(PDFArray*)otherArray
{
    return [self.nsa isEqualToArray:otherArray.nsa];
}

-(NSString*)description
{
    return [self.nsa description];
}

#pragma mark - Getter

-(NSArray*)nsa
{
    if(nsa == nil)
    {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        NSMutableArray* temp = [NSMutableArray array];
        
        NSUInteger count = 0;
        NSMutableArray* nsaFiller = nil;
        
        if(arr == NULL)
        {
            nsaFiller = [NSMutableArray array];
           
            PDFObjectParser* parser = [PDFObjectParser parserWithString:representation];
            
             for(id pdfObject in parser)[nsaFiller addObject:pdfObject];

            count = [nsaFiller count];

        }
        else count = CGPDFArrayGetCount(arr);
        
        
   
        
        for(NSUInteger c = 0 ; c < count; c++)
        {
            NSAutoreleasePool* poolPDFObject = [[NSAutoreleasePool alloc] init];
            id add = (arr!=NULL?[self pdfObjectAtIndex:c]:[nsaFiller objectAtIndex:c]);
            if(add != nil) 
            {
                [temp addObject:add];
            }
            [poolPDFObject drain];
        }
        
        nsa = [[NSArray arrayWithArray:temp] retain];
        [pool drain];
    }
        
    return nsa;
}

#pragma mark - Hidden

-(id)pdfObjectAtIndex:(NSUInteger)index
{
    
    
    if(arr == NULL)
    {
        return nil;
    }
    
    CGPDFObjectRef obj = NULL;
    if(CGPDFArrayGetObject(arr,index, &obj))
    {
        CGPDFObjectType type =  CGPDFObjectGetType(obj);
        switch (type) {
            case kCGPDFObjectTypeDictionary: return [self dictionaryAtIndex:index];
            case kCGPDFObjectTypeArray:      return [self arrayAtIndex:index];
            case kCGPDFObjectTypeString:     return [self stringAtIndex:index];
            case kCGPDFObjectTypeName:       return [self nameAtIndex:index];
            case kCGPDFObjectTypeInteger:    return [self integerAtIndex:index];
            case kCGPDFObjectTypeReal:       return [self realAtIndex:index];
            case kCGPDFObjectTypeBoolean:    return [self booleanAtIndex:index];
            case kCGPDFObjectTypeStream:     return [self streamAtIndex:index];
            case kCGPDFObjectTypeNull:   
            default:
                return nil;
        }
    }
    
    return nil;
}

-(PDFDictionary*)dictionaryAtIndex:(NSUInteger)index
{
    CGPDFDictionaryRef dr = NULL;
    if(CGPDFArrayGetDictionary(arr, index, &dr))
    {
        return [[[PDFDictionary alloc] initWithDictionary:dr] autorelease];
    }
    return nil;
}

-(PDFArray*)arrayAtIndex:(NSUInteger)index
{
    CGPDFArrayRef ar = NULL;
    if(CGPDFArrayGetArray(arr, index, &ar))
    {
        return [[[PDFArray alloc] initWithArray:ar] autorelease];
    }
    return nil;
}


-(NSString*)stringAtIndex:(NSUInteger)index
{
    CGPDFStringRef str = NULL;
    if(CGPDFArrayGetString(arr, index, &str))
    {
       return [(NSString*)CGPDFStringCopyTextString(str) autorelease];
       
    }
    return nil;
}


-(NSString*)nameAtIndex:(NSUInteger)index
{
    const char* targ = NULL;
    if(CGPDFArrayGetName(arr, index, &targ))
    {
        return [NSString stringWithUTF8String:targ];
    }
    
    return nil;
}

-(NSNumber*)integerAtIndex:(NSUInteger)index
{
    CGPDFInteger targ;
    if(CGPDFArrayGetInteger(arr, index, &targ))
    {
        return [NSNumber numberWithUnsignedInteger:(NSUInteger)targ];
    }
    return nil;
}


-(NSNumber*)realAtIndex:(NSUInteger)index
{
    CGPDFReal targ;
    if(CGPDFArrayGetNumber(arr, index, &targ))
    {
        return [NSNumber numberWithFloat:(float)targ];
    }
    return nil;
}


-(NSNumber*)booleanAtIndex:(NSUInteger)index
{
    CGPDFBoolean targ;
    if(CGPDFArrayGetBoolean(arr, index, &targ))
    {
        return [NSNumber numberWithBool:(BOOL)targ];
    }
    return nil;
}


-(PDFStream*)streamAtIndex:(NSUInteger)index
{
    CGPDFStreamRef targ = NULL;
    if(CGPDFArrayGetStream(arr, index, &targ))
    {
        return [[[PDFStream alloc] initWithStream:targ] autorelease];
    }
    return nil;
}


#pragma mark - NSFastEnumeration


-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id [])buffer count:(NSUInteger)len
{
    return [self.nsa countByEnumeratingWithState:state objects:buffer count:len];
}

#pragma mark - Representation

-(NSString*)pdfFileRepresentation
{
    if(representation)return representation;
    
    NSMutableString* ret = [NSMutableString stringWithString:@"["];
    for(int i = 0  ; i < [self count];i++)
    {
        [ret appendFormat:@" %@",[PDFUtility pdfObjectRepresentationFrom:[self objectAtIndex:i] Type:[self typeAtIndex:i]]];
    }
    
    [ret appendString:@"]"];
    
    return [NSString stringWithString:ret];
}


@end
