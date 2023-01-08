# PDF::Checker

Welcome to PDF::Checker and easy test your PDF documents.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pdf-checker'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install pdf-checker

## Usage

Make a "PDF checker":

~~~ruby

pdf = PDF::Checker.new("path/to/your/doc.pdf")

~~~

… and use it to check your document in detail.

For instance:

~~~ruby
require 'test_helper'

class MyPdfTester < Minitest::Test

  def pdf
    @pdf ||= PDF::Checker.new("path/to/your/doc.pdf")
  end

  def test_my_pdf_doc
    
    pdf.page(2).has_text("Hello word!").with(**{font: :"F1.0", at:[20,50]})
    # => fails if page 2 of document doesn't contains a text
    #     in :F1.0 font, at 20 points left and 50 points top.
    #     succeed otherwise

    pdf.page(3).has_image('myimage.jpg').at(300, 688).with(**{width:200.px})

  end

end

~~~

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/PhilippePerret/pdf-checker.

