require_relative 'assertion'
module PDF
class Checker
class FontAssertion < PDF::Checker::Assertion

attr_reader :font_name

def initialize(owner, font_name, **options)
  super
  @font_name = font_name
end

# = main =
# 
# Main method which check the font name of the owner (PDF::Checker::Page)
# 
def proceed
  font_names = case font_name
  when String, Symbol then [font_name]
  when Array  then font_name
  else raise(ArgumentError.new("La fonte doit être un String, un Symbol ou une liste."))
  end

  # 
  # On passe en revue toutes les fontes
  # Le nom fourni au test peut être soit la clé de la table fontes,
  # soit le paramètre BaseFont.
  # 
  font_names.each do |fname|
    fname = fname.to_s
    if font?(fname) == not(negative?)
      assert(true) # juste pour générer une assertion
    else
      err_msg = ERRORS[:failures][:page_should_contain_font] % [fname.inspect, fontes_list]
      assert(false, err_msg)
    end
  end

end

def with_properties(**props)
  puts "Je dois apprendre à tester les propriétés #{props.inspect}.".jaune
end
alias :with :with_properties


private

  # @return [Boolean] true if fonts page contains +fname+
  # 
  # @param [String|Symbol] fname Name of the tested font
  # 
  def font?(fname)
    fontes.key?(fname.to_sym) || basefonts.include?(fname.to_s)
  end

  # 
  # Toutes les fontes de la page
  # 
  # C'est une table de cette forme :
  # {
  #   :"F1.0" => {
  #     Type:       :Font, 
  #     Subtype:    :Type1, 
  #     BaseFont:   :Courier, 
  #     Encoding:   :WinAnsiEncoding
  #   }
  # }
  def fontes
    @fontes ||= owner.fonts
  end

  def basefonts
    @basefonts ||= fontes.map {|kfont, dfont| dfont[:BaseFont].to_s }
  end


  # Pour le message d'erreur, la liste des fontes
  # @api private
  #
  def fontes_list
    @fontes_list ||= begin
      fontes.map do |kfont, dfont|
        "#{kfont.inspect} (#{dfont[:BaseFont].inspect})"
      end.pretty_join
    end
  end

end #/class FontAssertion
end #/class Checker
end #/module PDF
