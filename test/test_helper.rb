$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "pdf/checker"

require "minitest/autorun"
require 'minitest/color'
require 'minitest/reporters'

reporter_options = { 
  color: true,          # pour utiliser les couleurs
  slow_threshold: true, # pour signaler les tests trop longs
}
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]

ASSETS_FOLDER = File.join(__dir__,'assets')
TRY_FOLDER    = File.join(ASSETS_FOLDER,'essais')

module Minitest::Assertions

  ##
  # Quand on attend un échec (failure)
  # 
  def assert_fails(with_message = nil, &block)
    if block_given?
      err = assert_raises(Minitest::Assertion) do
        @assertions -= 1
        yield
      end
      if with_message
        @assertions -= 1
        assert_match(with_message, err.message, "L'affirmation échoue bien, mais elle devrait échouer avec le message #{with_message.inspect}. Elle échoue avec #{err.message.inspect}.")
      end
    else
      raise "Il faut fournir un bloc à assert_fails"
    end
  end
  alias :assert_failure :assert_fails

  def assert_success( err_msg = nil, &block)
    if block_given?
      problemo = nil
      begin
        yield
      rescue Minitest::Assertion => e
        problemo = e
      end
      refute(problemo, "L'affirmation n'aurait pas dû échouer… Elle a échoué avec le message #{problemo && problemo.message.inspect}.")
      # 
      # Mais une assertion a-t-elle bien été produite ?
      # 
      # TODO : je ne sais pas encore le savoir, puisque @assertions
      # semble être une variable d'instance, et deux instances différentes
      # sont donc utilisées, entre celle-ci et celle jouée dans le
      # code testé.
    else
      raise "Il faut fournir un bloc à assert_success !"
    end
  end
  alias :assert_not_fails :assert_success
end #/module Minitest
