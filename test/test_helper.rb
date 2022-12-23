$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "pdf/checker"

require "minitest/autorun"
require 'minitest/color'

ASSETS_FOLDER = File.join(__dir__,'assets')
