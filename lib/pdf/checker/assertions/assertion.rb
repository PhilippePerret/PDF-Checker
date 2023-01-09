module PDF
class Checker
  class Assertion
    include Minitest::Assertions

    attr_reader :owner
    attr_accessor :assertions
    attr_reader :searched
    attr_reader :options

    def initialize(owner, searched, options)
      @owner      = owner # page
      @searched   = searched # image path, liste de texte|regstr…
      @options    = options  # à commencer par le message d'erreur
      @assertions = 0 # pour Minitest
    end

    def negative?
      :TRUE == @isnegative ||= (options[:negative] ? :TRUE : :FALSE)
    end

    def expected_count
      @expected_count ||= begin
        if options.key?(:count) && options[:count]
          options[:count]
        else
          false
        end
      end
    end

  end #/class NegAssertion
end #/class Checker
end #/module PDF
