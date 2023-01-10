require_relative 'assertion'
module PDF
class Checker
  class ImageAssertion < PDF::Checker::Assertion

    # def initialize(owner)
    #   super
    # end

    def proceed
      puts "Je dois apprendre à traiter une assertion d'image.".jaune
    end

    def with_properties(**props)
      puts "Je dois apprendre à tester l'image avec les propriétés #{props.inspect}.".jaune      
    end
    alias :with :with_properties

  end #/class NegAssertion
end #/class Checker
end #/module PDF
