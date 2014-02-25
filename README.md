#ILPDFKit

> A simple toolkit for filling out PDF forms, and extracting PDF data in iOS.


![screenshot](http://imgur.com/oo5HLUg.png "Screenshot" =250x)

## Installation

   Move the ILPDFKit folder and the ILPDFKit.xcodeproj file to your app directory. Add ILPDFKit.xcodeproj to your app project. Ensure your app links against the libILPDFKit.a target. Then you should be good to go.

## Quick Start

 The quickest way to get started with ILPDFKit is to take a look at the included sample app. For example, to view a PDF form resource named 'test.pdf' you can do the following: 
    
```objective-c
#import "PDF.h"

_pdfViewController = [[PDFViewController alloc] initWithResource:@"test.pdf"];
    
// Manually set a form value
[_pdfViewController.document.forms setValue:@"Derek" ForFormWithName:@"Contacts.FirstName"];
    
// Save via a flat PDF.
NSData* flatPDF = [_pdfViewController.document flatten]

// Save directing to the original document, preserving interactive features
[_pdfViewController.document saveFormsToDocumentData^(BOOL success) {
		/* At this point, _pdfViewController.documentData represents the updated PDF.
	   	   You can do as you wish with it. Upload, save to disk etc.
		*/
}];

```

## PDF Support 

ILPDFKit currently supports a narrow range of PDF versions and is not suitable for a production app that needs to save general PDF files from versions 1.3 to 1.7
  
 PDF features that cause issues with saving include:
  
  1. Linearized PDF files (Linearization is broken after save. File will open correctly using UIWebView, Preview, and Chrome but Adobe reader fails)
  
  2. Object Streams (This library can not currently save fields stored in object streams, introduced in PDF 1.5 , files that use object streams are sometimes refered to as compressed files as object streams can compress PDF objects in the file).
  
## Features




  For this version, all features are considered experimental. Expanded features and documentation will be released in subsequent versions.
  
  * View and interact with PDF forms (Button, Text, and Choice)
  * Extract and modify AcroForm values.
  * Support for JavaScript PDF actions (A, E and K keys) (Limited)
  * Save form data to the original PDF file (See limitations above)
  * Created XML respresentation of all forms and data for form submission.
  * Easy introspection using PDFDocument, PDFPage, PDFDictionary and PDFArray.
  * Rapidly, parse, extract and analyze PDF document structure, data and properties.
  
  
## Usage


### Filling out Forms

```objective-c
_pdfViewController = [[PDFViewController alloc] initWithResource:@"test.pdf"];

[self.window setRootViewController:_pdfViewController];
// Have fun filling out the form.
```


### Getting/Setting Form Values Explicity

```objective-c
for(PDFForm* form in _pdfViewController.document.forms)
{
	// Get
	NSString* formValue = form.value;
	NSString* formName = form.name; // Fully qualified field name.
	
	// Set
	form.value = @"foo";
	// If the form is visible on screen it will updated automatically.
}
```


### Saving Forms

```objective-c
[_pdfViewController.document saveFormsToDocumentData^(BOOL success) {
	/* At this point, _pdfViewController.documentData represents the updated PDF.
   	   You can do as you wish with it. Upload, save to disk etc.
	*/
}];
```
	 
	
### Sending Form XML Data 
```objective-c
NSString* documentFormsXML = [_pdfViewController.document formsXML];
// Push to webservice
```
	


## Documentation

[CocoaDocs](http://cocoadocs.org/docsets/ILPDFKit)



## Contact


[Derek Blair](http://github.com/derekblair)
[@derekblr](https://twitter.com/derekblr)

## License

(The MIT License)

Copyright (c) 2013 Derek Blair &lt;derekjblair@gmail.com&gt;

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
