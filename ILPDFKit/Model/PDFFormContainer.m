//  Created by Derek Blair on 2/24/2014.
//  Copyright (c) 2014 iwelabs. All rights reserved.

#import "PDFFormContainer.h"
#import "PDFDocument.h"
#import "PDFForm.h"
#import "PDFDictionary.h"
#import "PDFPage.h"
#import "PDFFormAction.h"
#import "PDFStream.h"
#import "PDFWidgetAnnotationView.h"
#import "PDFFormChoiceField.h"
#import "PDFUtility.h"

@interface PDFFormContainer()
    -(void)populateNameTreeNode:(NSMutableDictionary*)node WithComponents:(NSArray*)components Final:(PDFForm*)final;
    -(NSArray*)formsDescendingFromTreeNode:(NSDictionary*)node;
    -(void)applyAnnotationTypeLeafToForms:(PDFDictionary*)leaf Parent:(PDFDictionary*)parent PageMap:(NSDictionary*)pmap;
    -(void)enumerateFields:(PDFDictionary*)fieldDict PageMap:(NSDictionary*)pmap;
    -(NSArray*)allForms;
    -(NSString*)formXMLForFormsWithRootNode:(NSDictionary*)node;
    -(void)addForm:(PDFForm*)form;
    -(void)removeForm:(PDFForm*)form;

@end

@interface PDFFormContainer(JavascriptExecution)<UIWebViewDelegate>
  -(void)initializeJS;
  -(void)loadJS;
  -(NSString*)delimeter;
  -(void)executeJS:(NSString*)js;
  -(void)setDocumentValue:(NSString*)value ForKey:(NSString*)key;
  -(NSString*)getDocumentValueForKey:(NSString*)key;
  -(void)setEventValue:(id)value;
@end

@implementation PDFFormContainer
{
    
    NSMutableArray* _formsByType[PDFFormTypeNumberOfFormTypes];
    NSMutableArray* _allForms;
    NSMutableDictionary* _nameTree;
    UIWebView* _jsParser;
}


#pragma mark - NSObject


-(void)dealloc
{
    for(NSUInteger i = 0 ; i < PDFFormTypeNumberOfFormTypes ; i++)_formsByType[i] = nil;
}


#pragma mark - Initialization

-(id)initWithParentDocument:(PDFDocument*)parent
{
    self = [super init];
    if(self!=nil)
    {
        for(NSUInteger i = 0 ; i < PDFFormTypeNumberOfFormTypes ; i++)_formsByType[i] = [[NSMutableArray alloc] init];
        _allForms = [[NSMutableArray alloc] init];
        _nameTree = [[NSMutableDictionary alloc] init];
        _document = parent;
        NSMutableDictionary* pmap = [NSMutableDictionary dictionary];
        for(PDFPage* page in _document.pages)
        {
            [pmap setObject:[NSNumber numberWithUnsignedInteger:page.pageNumber] forKey:[NSNumber numberWithUnsignedInteger:(NSUInteger)(page.dictionary.dict)]];
        }
        for(PDFDictionary* field in [[_document.catalog objectForKey:@"AcroForm"] objectForKey:@"Fields"])
        {
            [self enumerateFields:field PageMap:pmap];
        }
        
        [self loadJS];
    }
    return self;
}




#pragma mark - Getting Forms

-(NSArray*)formsWithName:(NSString*)name
{
    id current = _nameTree;
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
    return _formsByType[type];
}

-(NSArray*)allForms
{
    return _allForms;
}


#pragma mark - Adding and Removing Forms

-(void)addForm:(PDFForm*)form
{
    [_formsByType[form.formType] addObject:form];
    [_allForms addObject:form];
    [self populateNameTreeNode:_nameTree WithComponents:[form.name componentsSeparatedByString:@"."] Final:form];
}

-(void)removeForm:(PDFForm*)form
{
    [_formsByType[form.formType] removeObject:form];
    [_allForms removeObject:form];
    
    id current = _nameTree;
    NSArray* comps = [form.name componentsSeparatedByString:@"."];
    
    for(NSString* comp in comps)
    {
        current = [current objectForKey:comp];
    }
    
    [current removeObject:form];
}


#pragma mark - Hidden



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
    PDFForm* form = [[PDFForm alloc] initWithFieldDictionary:leaf Page:[_document.pages objectAtIndex:index] Parent:self];
    [self addForm:form];
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

#pragma mark - Form Value Setting


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
    [ret appendString:[self formXMLForFormsWithRootNode:_nameTree]];
    [ret appendString:@"\r</fields>"];
    return [[[ret stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"] stringByReplacingOccurrencesOfString:@"&amp;#60;" withString:@"&#60;"] stringByReplacingOccurrencesOfString:@"&amp;#62;" withString:@"&#62;"];
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
            if([form.value length])[ret appendFormat:@"\r<%@>%@</%@>",key,[PDFUtility urlEncodeStringXML: form.value],key];
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


-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    return [[self allForms] countByEnumeratingWithState:state objects:buffer count:len];
}


-(NSArray*)createWidgetAnnotationViewsForSuperviewWithWidth:(CGFloat)width Margin:(CGFloat)margin HMargin:(CGFloat)hmargin
{
    NSMutableArray* ret = [[NSMutableArray alloc] init];
    for(PDFForm* form in self)
    {
        if(form.formType == PDFFormTypeChoice)continue;
        id add = [form createWidgetAnnotationViewForSuperviewWithWidth:width XMargin:margin YMargin:hmargin];
          if(add) [ret addObject:add];
    }
    NSMutableArray* temp = [[NSMutableArray alloc] init];
    
    
    //We keep choice fileds on top.
    for(PDFForm* form in [self formsWithType:PDFFormTypeChoice])
    {
        id add = [form createWidgetAnnotationViewForSuperviewWithWidth:width XMargin:margin YMargin:hmargin];
        if(add) [temp addObject:add];
    }
    
    [temp sortUsingComparator:^NSComparisonResult(PDFFormChoiceField* obj1, PDFFormChoiceField* obj2) {
        
        if( obj1.baseFrame.origin.y > obj2.baseFrame.origin.y)return NSOrderedAscending;
        return NSOrderedDescending;
    }
     ];
    [ret addObjectsFromArray:temp];
    return ret;
}

#pragma mark - Scripting


-(void)executeScript:(NSString*)script
{
    [self executeJS:script];
}

@end



@implementation PDFFormContainer(JavascriptExecution)


#pragma mark - Javascript


-(void)setEventValue:(id)value
{
    [self setDocumentValue:value ForKey:@"EventValue"];
}


-(NSString*)delimeter
{
    return @"*delim*";
}

-(void)executeJS:(NSString*)js
{
    [self setDocumentValue:@"" ForKey:@"SubmitForm"];
    
    for(PDFForm* form in [self allForms])
    {
        if(form.value)
        {
            NSString* set = [[form.value componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
            if([set isEqualToString:@" "])set = @"";
            
            [self setDocumentValue:set ForKey:[NSString stringWithFormat:@"Field(%@).%@",form.name,@"value"]];
        }
        
        
        if([form.options count])
        {
            NSString* set = [form.options componentsJoinedByString:[self delimeter]];
            
            [self setDocumentValue:set ForKey:[NSString stringWithFormat:@"Field(%@).%@",form.name,@"items"]];
        }
    }
    
    if([_jsParser stringByEvaluatingJavaScriptFromString:js])
    {
        for(PDFForm* form in [self allForms])
        {
            NSString* val = [self getDocumentValueForKey:[NSString stringWithFormat:@"Field(%@).%@",form.name,@"value"]];
            if([[[form actions] allValues] count] > 0)
            {
                NSString* opt = [self getDocumentValueForKey:[NSString stringWithFormat:@"Field(%@).%@",form.name,@"items"]];
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

-(void)setDocumentValue:(NSString*)value ForKey:(NSString*)key
{
    NSString* ckey = [key stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString* cvalue = [value stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    [_jsParser stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setDocumentKeyValue(\"%@\",\"%@\")",ckey ,cvalue]];
}

-(NSString*)getDocumentValueForKey:(NSString*)key
{
    NSString* ckey = [key stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString* ret = [_jsParser stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"getDocumentValueForKey(\"%@\")",ckey]];
    if([ret length] == 0)return nil;
    return ret;
}

-(void)initializeJS
{
    
    for(PDFForm* form in self)
    {
        [self setDocumentValue:[NSString stringWithFormat:@"%@",form.name] ForKey:[NSString stringWithFormat:@"Field(%@).%@",form.name,@"name"]];
        
        if([form.options count] && [[form.actions allValues] count]==0)
        {
            NSString* set = @"";
            for(NSString* comp in form.options)set = [set stringByAppendingString:[NSString stringWithFormat:@"%@%@",comp,[self delimeter]]];
            set = [set substringToIndex:[set length]-[[self delimeter] length]];
            [self setDocumentValue:set ForKey:[NSString stringWithFormat:@"Field(%@).%@",form.name,@"items"]];
        }
    }
    
    for(PDFForm* form in [self formsWithType:PDFFormTypeChoice])
    {
        [[form.actions objectForKey:@"E"] execute];
    }
}

-(void)loadJS
{
    _jsParser = [[UIWebView alloc] init];
    _jsParser.delegate = self;
    NSString* javascript = @"<html><head><script>function Event(){this.__defineGetter__('value',function(){return getDocumentValueForKey('EventValue')});this.__defineGetter__('willCommit',function(){return true})}function logArray(e){var t='';for(var n=0;n<e.length-1;n++){if(typeof e[n]!='undefined')t=t+e[n]+'*delim*'}if(typeof e[e.length-1]!='undefined')t=t+e[e.length-1];return t}function sizeArray(e){var t=0;for(var n=0;n<e.length;n++){if(typeof e[n]!='undefined')t++}return t}function Field(e){this.name=e;this.type=getDocumentValueForKey('Field('+e+').type');this.items=[];var t=getDocumentValueForKey('Field('+e+').items');if(t!=null){if(t.length==0)this.items=[];else this.items=t.split('*delim*')}var n=getDocumentValueForKey('Field('+e+').value');this.__defineGetter__('value',function(){return n});this.__defineSetter__('value',function(e){n=e;setDocumentKeyValue('Field('+this.name+').value',e)});this.__defineGetter__('numItems',function(){return sizeArray(this.items)});this.setAction=function(e,t){};this.clearItems=function(){this.items=[];setDocumentKeyValue('Field('+this.name+').items',logArray(this.items))};this.insertItemAt=function(e,t){this.items[t]=e;setDocumentKeyValue('Field('+this.name+').items',logArray(this.items))}}function getField(e){var t=getDocumentValueForKey('Field('+e+').name');if(t!=null)return new Field(t);return null}function getPrintParams(){return null}function print(e){}function submitForm(e){var t='';for(property in e){t+=property+':'+e[property]+';'}setDocumentKeyValue('SubmitForm',t)}function setDocumentKeyValue(e,t){store[e]=t}function getDocumentValueForKey(e){return store[e]}window.event=new Event;window.store=new Object</script></head><body></body></html>";
    NSData* htmlData = [javascript dataUsingEncoding:NSUTF8StringEncoding];
    [_jsParser loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:@"localhost"]];
}

#pragma mark - UIWebDelegate

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self initializeJS];
}


@end
