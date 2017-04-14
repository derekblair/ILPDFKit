![ILPDFKit Logo](	
https://s3-eu-west-1.amazonaws.com/derekblair/ilpdfkit.png)

[![CI Status](http://img.shields.io/travis/derekblair/ILPDFKit.svg?style=flat)](https://travis-ci.org/derekblair/ILPDFKit)
[![Version](https://img.shields.io/cocoapods/v/ILPDFKit.svg?style=flat)](http://cocoapods.org/pods/ILPDFKit)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![Swift](https://img.shields.io/badge/%20in-swift%203.0-orange.svg)
[![License](https://img.shields.io/cocoapods/l/ILPDFKit.svg?style=flat)](http://cocoapods.org/pods/ILPDFKit)
[![Platform](https://img.shields.io/cocoapods/p/ILPDFKit.svg?style=flat)](http://cocoapods.org/pods/ILPDFKit)


> A simple, minimalist toolkit for filling out PDF forms, and extracting PDF data in iOS, that extends *WKWebView* and the *CoreGraphics PDF C API*.

![screenshot](http://imgur.com/oo5HLUg.png)

## Features

- [x] Parse and analyze PDF documents with easy API.
- [x] Fill out and save PDF AcroForms to a flat non-editable PDF.
- [x] Handle text, button and combo fields.
- [x] Easy introspection using PDFDocument, PDFPage, PDFDictionary and PDFArray.
- [x] Rapidly, parse, extract and analyze PDF document structure, data and properties.
- [ ] Handle signature fields.
- [ ] Save AcroForm values to the original, editable PDF.
- [ ] Comprehensive Unit and Integration Test Coverage
- [ ] [Swift Documentation](http://cocoadocs.org/docsets/ILPDFKit)

## Requirements

- iOS 9.0+
- Xcode 8.1+
- Swift 3.0+

## Installation

### Manually 
 You may simply add all the source files in the ILPDFKit folder to your project. Using this method, you must use ARC and link against the `UIKit` and `QuartzCore` frameworks. 
 
### Cocoapods
 Alternatively, you may use CocoaPods, with the pod:
 
```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod ILPDFKit
end  
```

Then, run the following command:
`pod install`
 
### Carthage

To integrate ILPDFKit into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "derekblair/ILPDFKit"
```

Run `carthage update` to build the framework and drag the built `ILPDFKit.framework` into your Xcode project.

## Quick Start

 The quickest way to get started with ILPDFKit is to take a look at the included sample app. For example, to view a PDF form resource named 'test.pdf' you can do the following: 
 
 
```swift
let document = ILPDFDocument(resource:"myPDF")
// Manually set a form value
document.forms.setValue("Derek", forFormWithName: "Contacts.FirstName")
// Save via a static PDF.
let flatPDF = document.savedStaticPDFData()
```

## PDF Support 

ILPDFKit currently supports a narrow range of PDF versions and is not suitable for a production app that needs to save general PDF files from versions 1.3 to 1.7
  
 PDF features that cause issues with saving include:
  
  1. Linearized PDF files (Linearization is broken after save. File will open correctly using WKWebView, Preview, and Chrome but Adobe reader fails)
  
  2. Object Streams (This library can not currently save fields stored in object streams, introduced in PDF 1.5 , files that use object streams are sometimes referred to as compressed files as object streams can compress PDF objects in the file).
  
  
## Usage

### Filling Out Forms

```swift
pdfViewController = ILPDFViewController(resource:"test.pdf")
window.rootViewController = pdfViewController
// Have fun filling out the form.
```

### Getting/Setting Form Values Explicitly

```swift
for form in pdfViewController.document.forms {
	// Get
	let formValue = form.value;
	let formName = form.name; // Fully qualified field name.
	// Set
	form.value = "foo";
	
	// If the form is visible on screen it will updated automatically.
	// You can access the actual associated widget annotation view as below.
	// let widgetView = form.associatedWidget()
}
```
	

## Contact

[derekjblair@gmail.com](mailto:derekjblair@gmail.com)

## License

(The MIT License)

Copyright (c) 2017 Derek Blair &lt;derekjblair@gmail.com&gt;

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
