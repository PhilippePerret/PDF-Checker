require 'yaml'
require 'pdf/inspector'
require 'clir'
require 'prawn'
require "prawn/measurement_extensions" # to use 1.cm etc.
# Prawn::Fonts::AFM.hide_m17n_warning = true
require 'pdf/checker/constants'
require 'pdf/checker/config'
require 'pdf/checker/active_checker_module'
require "pdf/checker/version"
require "pdf/checker/integer"
require 'pdf/checker/pdf_checker'
require 'pdf/checker/metadata'
require 'pdf/checker/pages'
require 'pdf/checker/Page'
require 'pdf/checker/Page_Text'
require 'pdf/checker/receivers'
require 'pdf/checker/assertions'
require 'pdf/checker/assertions_pages'
require 'pdf/checker/level_matcher'

module Pdf
  module Checker
    class Error < StandardError; end
    # Your code goes here...
  end
end
