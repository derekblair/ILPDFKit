
#import "PDFObjectParser.h"
#import "PDFUtility.h"
#import "PDFDocument.h"
#import "PDFObject.h"




@interface NSString(Test)
-(id)objectForKey:(NSString*)key;
@end


@implementation NSString(Test)

-(id)objectForKey:(NSString*)key
{
    NSLog(@"the string causing problems is %@",self);
    return nil;
}

@end

#define isDelim(c) ((c) == '(' || (c) == ')' || (c) == '<' || (c) == '>' || (c) == '[' || (c) == ']' || (c) == '{' || (c) == '}' || (c) == '/' ||  (c) == '%')
#define isWS(c) ((c) == 0 || (c) == 9 || (c) == 10 || (c) == 12 || (c) == 13 || (c) == 32)
#define isODelim(c) ((c) == '(' ||  (c) == '<' ||  (c) == '[')
#define isCDelim(c) ((c) == ')' ||  (c) == '>' ||  (c) == ']')


typedef struct
{
    NSUInteger index;
    NSUInteger nestCount;
    NSUInteger startOfScanIndex;
}
PDFObjectParserState;


@interface PDFObjectParser()
-(id)pdfObjectFromString:(NSString*)st;
-(id)parseNextElement:(PDFObjectParserState*)state;
@end


@implementation PDFObjectParser
{
    NSString* _str;
    PDFDocument* _parentDocument;
}

-(void)dealloc
{
    [_str release];
    [super dealloc];
}

+(PDFObjectParser*)parserWithString:(NSString *)strg Document:(PDFDocument*)parentDocument
{
    return [[[PDFObjectParser alloc] initWithString:strg Document:parentDocument] autorelease];
    
}

-(id)initWithString:(NSString *)strg Document:(PDFDocument*)parentDocument
{
    self = [super init];
    if(self!=nil)
    {
      
        _parentDocument = parentDocument;
        
        if([strg characterAtIndex:0]=='<')
        {
            _str = [strg substringWithRange:NSMakeRange(1, strg.length-2)] ;
        }
        else _str = strg;
        
        if(_str)
        {
            
            //Here we replace indirect object references with a representation that is more easily parsed on the next step.
            NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:@"(\\d+)\\s+(\\d+)\\s+[R](\\W)" options:0 error:NULL];
            _str = [regex stringByReplacingMatchesInString:_str options:0 range:NSMakeRange(0, _str.length) withTemplate:@"($1,$2,ioref)$3"];
            [regex release];
        }
        
        [_str retain];
    }
    return self;
}

-(id)parseNextElement:(PDFObjectParserState*)state
{
    NSUInteger index = state->index;
    NSUInteger nestCount = state -> nestCount;
    NSUInteger startOfScanIndex = state -> startOfScanIndex;
    id ret = nil;
    
    while(index < _str.length)
    {
    
        NSRange range = {0,0};
        
        unichar cur = [_str characterAtIndex:index];
        
        BOOL found = NO;
        BOOL ws = isWS(cur);
        BOOL od = isODelim(cur);
        BOOL cd = isCDelim(cur);
        BOOL dl = isDelim(cur);
        if(od)nestCount++;
        if(cd)nestCount--;
        
        if(startOfScanIndex == 0)
        {
            if(ws == NO && (nestCount-od) == 1)startOfScanIndex = index;
        }
        else
        {
            range.location = startOfScanIndex;
            range.length = index - startOfScanIndex;
            found = YES;
            
            if(nestCount == 1 && (ws||cd))
            {
                startOfScanIndex = 0;
                range.length+=cd;
            }
            else if(((nestCount <= 1) && dl)||(nestCount == 2 && od))
            {
                startOfScanIndex = index; 
            }
            else found = NO;
        }
        
        index++;
            
        if(found)
        {
            ret =  [self pdfObjectFromString:[_str substringWithRange:range]];
            break;
        }
        
    }
    
    state->index = index;
    state->nestCount = nestCount;
    state->startOfScanIndex = startOfScanIndex;
    return ret;
}

// the string passed musn't include an indirect object definition header. eg ' 7 0 obj '

-(id)pdfObjectFromString:(NSString*)st
{
    
    NSString* work = [st stringByTrimmingCharactersInSet:[PDFUtility whiteSpaceCharacterSet]];
    
    if([work hasSuffix:@"ioref)"] && [work characterAtIndex:0] == '(')
    {
        NSArray* tokens = [[work substringWithRange:NSMakeRange(1, work.length-1)] componentsSeparatedByString:@","];
        PDFObject* ret = [[PDFObject createWithObjectNumber:[[tokens objectAtIndex:0] integerValue] GenerationNumber:[[tokens objectAtIndex:1] integerValue] Document:_parentDocument] autorelease];
        return ret;
    }

    if([work characterAtIndex:0] == '(' && [work characterAtIndex:work.length-1] == ')')
        return [work substringWithRange:NSMakeRange(1, work.length-2)]; // String
    
    if([work characterAtIndex:0] == '<' && [work characterAtIndex:work.length-1] == '>' && [work characterAtIndex:1] != '<')
        return [[work substringWithRange:NSMakeRange(1, work.length-2)] dataUsingEncoding:NSUTF8StringEncoding]; // HexString
    
    if([work characterAtIndex:0] == '/')
        return [work substringWithRange:NSMakeRange(1, work.length-1)]; // Name
    
    if( [work rangeOfCharacterFromSet:[[NSCharacterSet characterSetWithCharactersInString:@"0987654321+-."] invertedSet]].location == NSNotFound) // Real or Integer
    {
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber * rn = [f numberFromString:work];
        [f release];
        return rn;
    }
    
    //Boolean
    
    if([work isEqualToString:@"true"])return [NSNumber numberWithBool:YES];
    if([work isEqualToString:@"false"])return [NSNumber numberWithBool:NO];
    if([work isEqualToString:@"null"])return nil;
    
    return [[PDFObject createWithPDFRepresentation:work Document:_parentDocument] autorelease];
    
    
}

#pragma mark - NSFastEnumeration


    
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
    PDFObjectParserState parserState;
    
    if(state->state == 0)
    {
        parserState.index = 0;
        parserState.nestCount = 0;
        parserState.startOfScanIndex = 0;
        
    }
    else
    {
        parserState.index = (NSUInteger)(state->state);
        parserState.nestCount = (NSUInteger)((state->extra)[0]);
        parserState.startOfScanIndex = (NSUInteger)((state->extra)[1]);
        
    }
    

    NSUInteger batchCount = 0;
    while (parserState.index < _str.length && batchCount < len)
    {
        id obj = [self parseNextElement:&parserState];
        if(obj)
        {
            stackbuf[batchCount] = obj;
            batchCount++;
        }
    }
    
    state->state = (unsigned long)parserState.index;
    ((state->extra)[0]) = (unsigned long)parserState.nestCount;
    ((state->extra)[1]) = (unsigned long)parserState.startOfScanIndex;
    
    state->itemsPtr = stackbuf;
    state->mutationsPtr = (unsigned long *)self;
    
    return batchCount;
}




@end
