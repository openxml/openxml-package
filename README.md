# OpenXml::Package

A Ruby implementation of [DocumentFormat.OpenXml.Packaging.OpenXmlPackage](http://msdn.microsoft.com/en-us/library/documentformat.openxml.packaging.openxmlpackage_members(v=office.14).aspx) from Microsoft's Open XML SDK.

The base class for [Docx::Package](https://github.com/openxml/openxml-docx/blob/master/lib/openxml/docx/package.rb), [Xlsx::Package](https://github.com/openxml/openxml-xlsx/blob/master/lib/openxml/xlsx/package.rb), and [Pptx::Package](https://github.com/openxml/openxml-pptx).


## Installation

Add this line to your application's Gemfile:

    gem 'openxml-package'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install openxml-package



## Usage

#### Writing

You can assemble an Open XML Package in-memory and then write it to disk:

```ruby
package = OpenXml::Package.new
package.add_part "content/document.xml", OpenXml::Parts::UnparsedPart.new("<document></document>")
package.add_part "media/image.png", OpenXml::Parts::UnparsedPart.new(File.open(image_path, "rb", &:read))
package.write_to "~/Desktop/output.zip"
```


#### Reading

You can read the contents of an Open XML Package:

```ruby
OpenXmlPackage.open("~/Desktop/output.zip") do |package|
  package.parts.keys # => ["content/document.xml", "media/image.png"]
end
```


#### Subclassing

`OpenXml::Package` is intended to be the base class for libraries that implement Open XML formats for Microsoft Office products.

For example, a very simple Microsoft Word document can be defined as follows:

```ruby
require "openxml/package"

module Rocx
  class Package < OpenXml::Package
    attr_reader :document,
                :doc_rels,
                :settings,
                :styles

    content_types do
      default "png", TYPE_PNG
      override "/word/styles.xml", TYPE_STYLES
      override "/word/settings.xml", TYPE_SETTINGS
    end

    def initialize
      super

      rels.add_relationship REL_DOCUMENT, "/word/document.xml"
      @doc_rels = OpenXml::Parts::Rels.new([
        { type: REL_STYLES, target: "/word/styles.xml"},
        { type: REL_SETTINGS, target: "/word/settings.xml"}
      ])
      @settings = Rocx::Parts::Settings.new
      @styles = Rocx::Parts::Styles.new
      @document = Rocx::Parts::Document.new

      add_part "word/_rels/document.xml.rels", doc_rels
      add_part "word/document.xml", document
      add_part "word/settings.xml", settings
      add_part "word/styles.xml", styles
    end

  end
end
```

This gem also defines two "Parts" that are commonly used in Open XML packages.

##### OpenXml::Parts::ContentTypes

Is used to identify the ContentType of all of the files in the package. There are two ways of identifying content types:

 1. **Default**: declares the default content type for a file with a given extension
 2. **Override**: declares the content type for a specific file with the given path inside the package

##### OpenXml::Parts::Rels

Is used to identify links within the package



## Contributing

1. Fork it ( https://github.com/openxml/openxml-package/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

#### Reference

 - [DocumentFormat.OpenXml.Packaging.OpenXmlPackage](http://msdn.microsoft.com/en-us/library/documentformat.openxml.packaging.openxmlpackage_members(v=office.14).aspx)
 - [DocumentFormat.OpenXml.Packaging.OpenXmlPartContainer](http://msdn.microsoft.com/en-us/library/documentformat.openxml.packaging.openxmlpartcontainer_members(v=office.14).aspx)
 - [DocumentFormat.OpenXml.Packaging.OpenXmlPart](http://msdn.microsoft.com/en-us/library/documentformat.openxml.packaging.openxmlpart_members(v=office.14).aspx)
 - [System.IO.Packaging.Package](http://msdn.microsoft.com/en-us/library/system.io.packaging.package.aspx)
