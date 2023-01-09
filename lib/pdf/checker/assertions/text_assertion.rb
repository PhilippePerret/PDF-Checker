require_relative 'assertion'
module PDF
class Checker
  class TextAssertion < PDF::Checker::Assertion

    ##
    # --- Analyse ---
    # @searched contient les strings ou les regexp à trouver dans 
    # le propriétaire (@owner) de cette assertion.
    def proceed
      puts "Je dois apprendre à traiter une assertion textuelle #{'négative ' if negative?}sur #{searched.inspect}.".jaune
      # 
      # On met le texte cherché dans uen liste si c'est un texte ou
      # une expression régulière seule
      # 
      @searched = [searched] unless searched.is_a?(Array)
      # 
      # Table pour mettre les textes trouvés
      # 
      text_objects_found = {}
      # 
      # Pour mettre les matchers de texte-objets qui contiennent au
      # moins un des textes cherchés
      # 
      good_matchers = []
      # 
      # Pour mettre les mauvais machers (avec les raisons)
      # 
      bad_matchers = []
      # 
      # Boucle sur tous les objets textuels
      # 
      owner.texts_objects.each do |text_object|
        # 
        # On crée un matcher pour ce texte-objet
        # 
        matcher = PDF::Checker::TextObjectMatcher.new(text_object, options)
        # 
        # Boucle sur tous les textes cherchés pour savoir si 
        # l'objet texte les contient.
        # 
        searched.each do |regstr|
          # 
          # On regarde si ce matcher contient (ou ne contient pas) ce
          # texte|regexp cherché
          # 
          if matcher.does_or_neg_contains?(regstr, text_objects_found)
            good_matchers << matcher
          end
        end #/fin boucle sur tous les textes|regexp cherchés
      end

      # puts "nombre de good_matchers : #{good_matchers.count}"
      # puts "nombre de text_objects_found : #{text_objects_found.count}"

      if expected_count
        # 
        # Si un nombre exact est demandé, on doit l'avoir trouvé
        # 
        assert_equal(expected_count, text_objects_found.count)
      else
        # 
        # Si aucun nombre exact n'est demandé, on doit avoir trouvé
        # autant de textes qu'il y en avait demandé
        # 
        assert_equal(searched.count, text_objects_found.count)
      end
    end
    #/ #proceed

  end #/class TextAssertion

  class TextObjectMatcher
    attr_reader :text_object
    attr_reader :options
    def initialize(text_object, options)
      @text_object  = text_object
      @options      = options
      # 
      # Pour mettre les textes contenus (ou non contenus si négatif)
      # 
      @texts_matched  = []
    end

    def does_or_neg_contains?(searched, text_objects_found)
      regstr = searched.dup
      if regstr.is_a?(Array)
        regstr.each do |regstr|
          does_or_neg_contains?(regstr, text_objects_found) || return
        end
        return true
      else
        if case regstr
        when String
           if strict?
             content == regstr
           else
             content.include?(regstr)
           end
         when Regexp
           content.match?(regstr)
         end === not(negative?) then
         # 
         # 
         text_objects_found.key?(regstr) || text_objects_found.merge!(regstr => [])
         text_objects_found[regstr] << text_object
         @texts_matched << regstr
         # puts "- #{regstr.inspect} trouvé dans : #{content.inspect}"
         return true
       else
         # 
         # Texte non trouvé (positif) ou trouvé (négatif)
         # 
         # puts "- #{regstr.inspect} NON trouvé dans : #{content.inspect}"
         return false
       end
      end
    end
    #/ # contains?

    def content
      @content ||= text_object.content.freeze
    end

    def strict?
      :TRUE == @strictmode ||= (options[:strict] ? :TRUE : :FALSE)
    end
    def negative?
      :TRUE == @negmode ||= (options[:negative] ? :TRUE : :FALSE)
    end


  end #/class TextObjectMatcher
end #/class Checker
end #/module PDF
