
#import "PDFObjectParser.h"
#import "PDFUtility.h"
#import "PDFDocument.h"
#import "PDFObject.h"


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

-(void)dealloc
{
    [str release];
    [super dealloc];
}

+(PDFObjectParser*)parserWithString:(NSString *)strg 
{
    return [[[PDFObjectParser alloc] initWithString:strg] autorelease];
    
}


-(id)initWithString:(NSString *)strg 
{
    self = [super init];
    if(self!=nil)
    {
      
        
        if([strg characterAtIndex:0]=='<')
        {
            str = [strg substringWithRange:NSMakeRange(1, strg.length-2)] ;
        }
        else str = strg;
        
        
        
        if(str)
        {
            
            NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:@"(\\d+)\\s+(\\d+)\\s+[R]\\W" options:0 error:NULL];
            
            
            str = [regex stringByReplacingMatchesInString:str options:0 range:NSMakeRange(0, str.length) withTemplate:@"($1,$2,ioref)"];
            
            
            [regex release];
        }
        
        
        
        [str retain];
        
    }
    
    return self;
}

-(id)parseNextElement:(PDFObjectParserState*)state
{
    
    NSUInteger index = state->index;
    NSUInteger nestCount = state -> nestCount;
    NSUInteger startOfScanIndex = state -> startOfScanIndex;
    id ret = nil;
    
    while(index < str.length)
    {
    
        NSRange range = {0,0};
        
        unichar cur = [str characterAtIndex:index];
        
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
            ret =  [self pdfObjectFromString:[str substringWithRange:range]];
            break;
        }
        
    }
    
    state->index = index;
    state->nestCount = nestCount;
    state->startOfScanIndex = startOfScanIndex;
    return ret;
}


/*
-(BOOL)scanForIndirectObjectAtIndex:(NSUInteger)index
{
    
    
    NSString* test = [str substringFromIndex:index];
    
    NSUInteger loc = [test rangeOfString:@"R"].location;
    if(loc == NSNotFound)return NO;
    
    NSCharacterSet* numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    for(NSInteger c = loc+index-1; c>=0;c--)
    {
        unichar current = [str characterAtIndex:c];
        if([PDFUtility isWhiteSpace:current])continue;
        if([numbers characterIsMember:current] == NO)return NO;
        else break;
    }
    
    if(loc < test.length-1)
    {
        unichar next = [test characterAtIndex:loc+1];
        if([PDFUtility isWhiteSpace:next] == NO && [PDFUtility isDelimeter:next] == NO)return NO;
    }
    
    
    NSString* jam = [[test substringToIndex:loc] stringByTrimmingCharactersInSet:[PDFUtility whiteSpaceCharacterSet]];
    
    if(jam.length !=0 && [jam rangeOfCharacterFromSet:[numbers invertedSet]].location != NSNotFound)return NO;
    
    return YES;
}*/






-(id)pdfObjectFromString:(NSString*)st
{
    
    NSString* work = [st stringByTrimmingCharactersInSet:[PDFUtility whiteSpaceCharacterSet]];
    
    
    
    
    if([work rangeOfString:@"ioref"].location!= NSNotFound)
    {
        NSArray* tokens = [[work substringWithRange:NSMakeRange(1, work.length-1)] componentsSeparatedByString:@","];
        PDFObject* ret = [[[PDFObject alloc] initWithPDFRepresentation:nil] autorelease];
        ret.objectNumber = [[tokens objectAtIndex:0] integerValue];
        ret.generationNumber = [[tokens objectAtIndex:1] integerValue];
      
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
    
    /*
    //Indirect Reference
    if([work characterAtIndex:work.length-1] == 'R')
    {
        
        NSInteger objectNumber;
        NSInteger generationNumber;
        NSScanner* scanner = [NSScanner scannerWithString:work];
        [scanner scanInteger:&objectNumber];
        [scanner scanInteger:&generationNumber];
        
        NSString* rep = [NSString stringWithString:[parent codeForObjectWithNumber:objectNumber GenerationNumber:generationNumber]];
        return [self pdfObjectFromString:rep];
        
    }
    
    //Indirect Definition
    
    if(work.length>6 && [[work substringFromIndex:work.length-6] isEqualToString:@"endobj"])
    {
        NSUInteger loc = [work rangeOfString:@"obj"].location;
        if(loc!=NSNotFound)
        {
            
            NSScanner* scanner = [NSScanner scannerWithString:[work substringToIndex:loc]];
            NSInteger genN;
            NSInteger objN;
            [scanner scanInteger:&objN];
            [scanner scanInteger:&genN];
            
            NSString* final = [work substringFromIndex:loc+3];
            NSUInteger locf = [final rangeOfString:@"endobj" options:NSBackwardsSearch].location;
            
            PDFObject* ret = [[PDFObject createWithPDFRepresentation:[final substringToIndex:locf] Parent:parent] autorelease];
            
            ret.objectNumber = objN;
            ret.generationNumber = genN;
            return ret;
            
            
        }
        else return nil;
    }*/
    
    
    //Dictionary or Stream or Array
    
    return [[PDFObject createWithPDFRepresentation:work] autorelease];
    
    
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
    while (parserState.index < str.length && batchCount < len)
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
