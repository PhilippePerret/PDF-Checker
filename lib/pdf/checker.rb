require 'yaml'
require 'pdf/inspector'
require 'clir'
require 'prawn'
require "prawn/measurement_extensions" # to use 1.cm etc.
Prawn::Fonts::AFM.hide_m17n_warning = true
require 'pdf/checker/extensions/numeric'
require 'pdf/checker/extensions/string'
require 'pdf/checker/constants'
require 'pdf/checker/config'
require 'pdf/checker/active_checker_module'
require "pdf/checker/version"
require "pdf/checker/integer"
require 'pdf/checker/pdf_checker'
require 'pdf/checker/metadata'
require 'pdf/checker/pages'
require 'pdf/checker/Page'
require 'pdf/checker/text_object'
require 'pdf/checker/text_object_matcher'
require 'pdf/checker/receivers'
require 'pdf/checker/assertions'
require 'pdf/checker/assertions/assertion'
require 'pdf/checker/assertions/neg_assertion'
require 'pdf/checker/assertions/text_assertion'
require 'pdf/checker/assertions/font_assertion'
require 'pdf/checker/assertions/image_assertion'
require 'pdf/checker/assertions_pages'

module Pdf
  module Checker
    class Error < StandardError; end
    # Your code goes here...
  end
end
