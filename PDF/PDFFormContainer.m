

#import "PDFFormContainer.h"
#import "PDFDocument.h"
#import "PDFForm.h"
#import "PDFDictionary.h"
#import "PDFPage.h"
#import "PDFFormAction.h"
#import "PDFStream.h"
#import "PDFUIAdditionElementView.h"
#import "PDFFormChoiceField.h"
#import "PDFUtility.h"

@interface PDFFormContainer()
    -(void)populateNameTreeNode:(NSMutableDictionary*)node WithComponents:(NSArray*)components Final:(PDFForm*)final;
    -(NSArray*)formsDescendingFromTreeNode:(NSDictionary*)node;
    -(void)applyAnnotationTypeLeafToForms:(PDFDictionary*)leaf Parent:(PDFDictionary*)parent PageMap:(NSDictionary*)pmap;
    -(void)enumerateFields:(PDFDictionary*)fieldDict PageMap:(NSDictionary*)pmap;
    -(NSString*)delimeter;
    -(NSArray*)allForms;
    -(void)initializeJS;
    -(NSString*)formXMLForFormsWithRootNode:(NSDictionary*)node;
    -(void)loadJS;
@end

@implementation PDFFormContainer

@synthesize document;

-(void)dealloc
{
    for(NSUInteger i = 0 ; i < PDFFormTypeNumberOfFormTypes ; i++)[formsByType[i] release];
    [allForms release];
    [nameTree release];
    [jsParser release];
    [super dealloc];
}

-(id)initWithParentDocument:(PDFDocument*)parent
{
    self = [super init];
    if(self!=nil)
    {
        for(NSUInteger i = 0 ; i < PDFFormTypeNumberOfFormTypes ; i++)formsByType[i] = [[NSMutableArray alloc] init];
        allForms = [[NSMutableArray alloc] init];
        nameTree = [[NSMutableDictionary alloc] init];
        document = parent;
        NSMutableDictionary* pmap = [NSMutableDictionary dictionary];
        for(PDFPage* page in document.pages)
        {
            [pmap setObject:[NSNumber numberWithUnsignedInteger:page.pageNumber] forKey:[NSNumber numberWithUnsignedInteger:(NSUInteger)(page.dictionary.dict)]];
        }
        for(PDFDictionary* field in [[document.catalog objectForKey:@"AcroForm"] objectForKey:@"Fields"])
        {
            [self enumerateFields:field PageMap:pmap];
        }
        
        [self loadJS];
    }
    return self;
}   

-(NSArray*)formsWithName:(NSString*)name
{
    id current = nameTree;
    NSArray* comps = [name componentsSeparatedByString:@"."];
    
    for(NSString* comp in comps)
    {
        current = [current objectForKey:comp];
        if(current == nil)return nil;
        
        if([current isKindOfClass:[NSMutableArray class]])
        {
            if(comp == [comps lastObject])
                return current;
            else
                return nil;
        }
    }
    
    return [self formsDescendingFromTreeNode:current];
}


-(NSArray*)formsWithType:(PDFFormType)type
{
    return formsByType[type];
}

-(NSArray*)allForms
{
    return allForms;
}


-(void)addForm:(PDFForm*)form
{
    [formsByType[form.formType] addObject:form];
    [allForms addObject:form];
    [self populateNameTreeNode:nameTree WithComponents:[form.name componentsSeparatedByString:@"."] Final:form];
}

-(void)removeForm:(PDFForm*)form
{
    [formsByType[form.formType] removeObject:form];
    [allForms removeObject:form];
    
    id current = nameTree;
    NSArray* comps = [form.name componentsSeparatedByString:@"."];
    
    for(NSString* comp in comps)
    {
        current = [current objectForKey:comp];
    }
    
    [current removeObject:form];
}


#pragma mark - Hidden

-(NSString*)delimeter
{
    return @"*delim*";
}

-(void)enumerateFields:(PDFDictionary*)fieldDict PageMap:(NSDictionary*)pmap
{
    if([fieldDict objectForKey:@"Subtype"])
    {
        PDFDictionary* parent = [fieldDict objectForKey:@"Parent"];
        [self applyAnnotationTypeLeafToForms:fieldDict Parent:parent PageMap:pmap];
    }
    else
    {
        for(PDFDictionary* innerFieldDictionary in [fieldDict objectForKey:@"Kids"])
        {
            PDFDictionary* parent = [innerFieldDictionary objectForKey:@"Parent"];
            if(parent!=nil)[self enumerateFields:innerFieldDictionary PageMap:pmap];
            else [self applyAnnotationTypeLeafToForms:innerFieldDictionary Parent:fieldDict PageMap:pmap];
        }
    }
}

-(void)applyAnnotationTypeLeafToForms:(PDFDictionary*)leaf Parent:(PDFDictionary*)parent PageMap:(NSDictionary*)pmap
{
    NSUInteger targ = (NSUInteger)(((PDFDictionary*)[leaf objectForKey:@"P"]).dict);
    leaf.parent = parent;
    
    NSUInteger index = targ?([[pmap objectForKey:[NSNumber numberWithUnsignedInteger:targ]] unsignedIntegerValue] - 1):0;
    PDFForm* form = [[PDFForm alloc] initWithFieldDictionary:leaf Page:[document.pages objectAtIndex:index] Parent:self];
    [self addForm:form];
    [form release];
}

-(NSArray*)formsDescendingFromTreeNode:(NSDictionary*)node
{
    NSMutableArray* ret = [NSMutableArray array];
    for(NSString* key in [node allKeys])
    {
        id obj = [node objectForKey:key];
        
        if([obj isKindOfClass:[NSMutableArray class]])
        {
            [ret addObjectsFromArray:obj];
        }
        else
        {
            [ret addObjectsFromArray:[self formsDescendingFromTreeNode:obj]];
        }
    }
    return ret;
}


-(void)populateNameTreeNode:(NSMutableDictionary*)node WithComponents:(NSArray*)components Final:(PDFForm*)final
{
    NSString* base = [components objectAtIndex:0];
    
    if([components count] == 1)
    {
        NSMutableArray* arr = [node objectForKey:base];
        if(arr == nil)
        {
            arr = [NSMutableArray arrayWithObject:final];
            [node setObject:arr forKey:base];
        }
        else
        {
            [arr addObject:final];
        }
        return;
    }
    
    NSMutableDictionary* dict  = [node objectForKey:base];
    if(dict == nil)
    {
        dict = [NSMutableDictionary dictionary];
        [node setObject:dict forKey:base];
    }
   
    [self populateNameTreeNode:dict WithComponents:[components subarrayWithRange:NSMakeRange(1, [components count]-1)] Final:final];
}


#pragma mark - JS

-(void)executeJS:(NSString*)js
{
    [self setHTML5StorageValue:@"" ForKey:@"SubmitForm"];
    
    for(PDFForm* form in [self allForms])
    {
        if(form.value)
        {
            NSString* set = [[form.value componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
            if([set isEqualToString:@" "])set = @"";
            
            [self setHTML5StorageValue:set ForKey:[NSString stringWithFormat:@"Field(%@).%@",form.name,@"value"]];
        }
    }
    
    if([jsParser stringByEvaluatingJavaScriptFromString:js])
    {
        for(PDFForm* form in [self allForms])
        {
            NSString* val = [self getHTML5StorageValueForKey:[NSString stringWithFormat:@"Field(%@).%@",form.name,@"value"]];
            if([[[form actions] allValues] count] > 0)
            {
                NSString* opt = [self getHTML5StorageValueForKey:[NSString stringWithFormat:@"Field(%@).%@",form.name,@"items"]];
                if([opt length] > 0)
                {
                    form.options = [opt componentsSeparatedByString:[self delimeter]];
                }
                else
                {
                    form.options = nil;
                }
            }
            
            if([form.value isEqualToString:val] == NO && (form.value!=nil || val!=nil))
            {
                form.value = val;
                form.modified = YES;
            }
        }
    }
}

-(void)setHTML5StorageValue:(NSString*)value ForKey:(NSString*)key
{
    NSString* ckey = [key stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString* cvalue = [value stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    [jsParser stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setStorageKeyValue(\"%@\",\"%@\")",ckey ,cvalue]];
}

-(NSString*)getHTML5StorageValueForKey:(NSString*)key
{
    
    NSString* ckey = [key stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString* ret = [jsParser stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"getStorageValueForKey(\"%@\")",ckey]];
    if([ret length] == 0)return nil;
    return ret;
}

-(void)initializeJS
{
    [jsParser stringByEvaluatingJavaScriptFromString:@"localStorage.clear()"];
    for(PDFForm* form in self)
    {
        [self setHTML5StorageValue:[NSString stringWithFormat:@"%@",form.name] ForKey:[NSString stringWithFormat:@"Field(%@).%@",form.name,@"name"]];
        
        if([form.options count] && [[form.actions allValues] count]==0)
        {
            NSString* set = @"";
            for(NSString* comp in form.options)set = [set stringByAppendingString:[NSString stringWithFormat:@"%@%@",comp,[self delimeter]]];
            set = [set substringToIndex:[set length]-[[self delimeter] length]];
            [self setHTML5StorageValue:set ForKey:[NSString stringWithFormat:@"Field(%@).%@",form.name,@"items"]];
        }
    }
    
    for(PDFForm* form in [self formsWithType:PDFFormTypeChoice])
    {
        [[form.actions objectForKey:@"E"] execute];
    }
    
    
    
    if([[((PDFForm*)[[self formsWithName:@"localphysid"] lastObject]) value] length])
    {
        NSString* search = [((PDFForm*)[[self formsWithName:@"localphysid"] lastObject]) value];
        NSString* temp = [((PDFForm*)[[self formsWithName:@"physinfo"] lastObject]) value];
        NSString* dl = [NSString stringWithFormat:@"/%u&",[search integerValue]];
        NSUInteger start = [temp rangeOfString:dl].location+dl.length;
        NSUInteger end = start;
        while([temp characterAtIndex:end]!='&' && [temp characterAtIndex:end]!='/')end++;
        NSString* fin = [temp substringWithRange:NSMakeRange(start, end-start)] ;
        [self setValue:[PDFUtility decodeURLEncodedString:fin] ForFormWithName:@"localphysid"];
    }
    

}

-(void)loadJS
{
    jsParser = [[UIWebView alloc] init];
    jsParser.delegate = self;
    NSString* path = [[NSBundle mainBundle] pathForResource:@"parse" ofType:@"html"];
    NSURL* address = [NSURL fileURLWithPath:path];
    NSURLRequest* request = [NSURLRequest requestWithURL:address];
    [jsParser loadRequest:request];
}

#pragma mark - UIWebViewDidFinishLoading

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self initializeJS];
}

#pragma mark - Value Setting


-(void)setValue:(NSString*)val ForFormWithName:(NSString*)name
{
    for(PDFForm* form in [self formsWithName:name])
    {
        if((([form.value isEqualToString:val] == NO) && (form.value!=nil || val!=nil)))
        {
            form.value = val;
        }
    }
}

#pragma mark - formXML

-(NSString*)formXML
{
    NSMutableString* ret = [NSMutableString stringWithString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r<fields>"];
    [ret appendString:[self formXMLForFormsWithRootNode:nameTree]];
    [ret appendString:@"\r</fields>"];
    return [ret stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
}


-(NSString*)formXMLForFormsWithRootNode:(NSDictionary*)node
{
    NSMutableString* ret = [NSMutableString string];
    for(NSString* key in [node allKeys])
    {
        id obj = [node objectForKey:key];
        if([obj isKindOfClass:[NSMutableArray class]])
        {
            PDFForm* form = (PDFForm*)[obj lastObject];
            if([form.value length])[ret appendFormat:@"\r<%@>%@</%@>",key,form.value,key];
        }
        else
        {
            NSString* val = [self formXMLForFormsWithRootNode:obj];
            if([val length])[ret appendFormat:@"\r<%@>%@</%@>",key,val,key];
        }
    }
    return ret;
}


#pragma mark - NSFastEnumeration


-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id [])buffer count:(NSUInteger)len
{
    return [[self allForms] countByEnumeratingWithState:state objects:buffer count:len];
}


-(NSArray*)createUIAdditionViewsForSuperviewWithWidth:(CGFloat)width Margin:(CGFloat)margin
{
    NSMutableArray* ret = [[NSMutableArray alloc] init];
    for(PDFForm* form in self)
    {
        if(form.formType == PDFFormTypeChoice)continue;
        id add = [form createUIAdditionViewForSuperviewWithWidth:width Margin:margin];
          if(add) [ret addObject:add];
        [add release];
    }
    NSMutableArray* temp = [[NSMutableArray alloc] init];
    for(PDFForm* form in [self formsWithType:PDFFormTypeChoice])
    {
        id add = [form createUIAdditionViewForSuperviewWithWidth:width Margin:margin];
        if(add) [temp addObject:add];
        [add release];
    }
    
    [temp sortUsingComparator:^NSComparisonResult(PDFFormChoiceField* obj1, PDFFormChoiceField* obj2) {
        
        if( obj1.baseFrame.origin.y > obj2.baseFrame.origin.y)return NSOrderedAscending;
        return NSOrderedDescending;
    }
     ];
    [ret addObjectsFromArray:temp];
    [temp release];
    return ret;
}



@end
