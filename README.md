# OpenXmlPackage

A Ruby implementation of [DocumentFormat.OpenXml.Packaging.OpenXmlPackage](http://msdn.microsoft.com/en-us/library/documentformat.openxml.packaging.openxmlpackage_members(v=office.14).aspx) from Microsoft's Open XML SDK.




## Installation

Add this line to your application's Gemfile:

    gem 'open_xml_package'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install open_xml_package




## Usage

#### Writing

You can assemble an Open XML Package in-memory and then write it to disk:

```ruby
package = OpenXmlPackage.new
package.add_part "content/document.xml", document_part
package.add_part "media/image.png", image_part
package.write_to "~/Desktop/output.zip"
```

It's up to your client library to define `document_part` and `media_part`. At present, `OpenXmlPackage` only requires that they respond to `read`.


#### Reading

To Do.




## Contributing

1. Fork it ( https://github.com/[my-github-username]/open_xml_package/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

#### Reference

 - [DocumentFormat.OpenXml.Packaging.OpenXmlPackage](http://msdn.microsoft.com/en-us/library/documentformat.openxml.packaging.openxmlpackage_members(v=office.14).aspx)
 - [DocumentFormat.OpenXml.Packaging.OpenXmlPartContainer](http://msdn.microsoft.com/en-us/library/documentformat.openxml.packaging.openxmlpartcontainer_members(v=office.14).aspx)
 - [DocumentFormat.OpenXml.Packaging.OpenXmlPart](http://msdn.microsoft.com/en-us/library/documentformat.openxml.packaging.openxmlpart_members(v=office.14).aspx)
 - [System.IO.Packaging.Package](http://msdn.microsoft.com/en-us/library/system.io.packaging.package.aspx)
