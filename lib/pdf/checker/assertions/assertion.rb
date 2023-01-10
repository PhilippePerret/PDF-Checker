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
    @expected_count = nil
    @objects_found  = nil # sera la liste des objets quelconques trouvés
  end

  def negative?
    :TRUE == @isnegative ||= (options[:negative] ? :TRUE : :FALSE)
  end
  def strict?
    :TRUE == @isstrict ||= (options[:strict] ? :TRUE : :FALSE)
  end
  def count?
    not(expected_count.nil?)    
  end

  # @return [Integer|nil] Nombre d'éléments attendus. Peut être 
  # redéfini à tout moment, avec les options des méthodes
  def expected_count
    @expected_count ||= begin
      if options.key?(:count) && options[:count]
        options[:count]
      else
        nil
      end
    end
  end

  ##
  # Pour faire une recherche de positionnement
  # 
  # @param [Numeric|Hash] arg1 Soit la position top (si arg2 nil), soit un hash {:left, :top}, soit un array [<left>,<top>]
  def at(arg1, arg2 = nil, opts = nil)
    if @objects_found.nil?
      raise PDF::Checker::ERRORS[:failures][:searched_text_required_for_at_test]
    end
    # 
    # Mettre les opts tout de suite (elles peuvent être remplacées
    # par arg2 si c'est un Hash)
    # 
    if opts.nil? then opts = {}
    else @options.merge!(opts) 
    end
    # 
    # La table contenant les propriétés à estimer
    # 
    coors = get_coordonates_to_check(arg1, arg2)
    # puts "Coordonnées à tester : #{coors.inspect}".bleu
    # 
    # Y a-t-il un nombre d'éléments attendu ?
    # 
    @expected_count = opts.delete(:count) if opts[:count]
    #
    # Table pour mettre les objects (text-objects, image-objects, etc.)
    # qui passeront ce test
    # 
    good_objects = {}
    # 
    # Table pour mettre les mauvais (pour le message d'erreur éventuel)
    # 
    bad_objects = {}
    # 
    # Boucle sur tous les objets ayant passé les tests jusque-là
    # @note
    #   Pour le moment, j'ai une méthode commune, donc +regstr+ qui
    #   sert pour les textes mais aussi pour les images si on met
    #   le path de l'image. Mais pour les graphiques ?
    # 
    @objects_found.each do |regstr, objects|
      objects.each do |object|
        liste = object.matcher.has_properties?(**coors) ? good_objects : bad_objects
        liste.merge!(regstr => []) unless liste.key?(regstr)
        liste[regstr] << object
      end
    end

    # 
    # Si le nombre de nouveaux objets (en fait, le nombre de clés)
    # correspond au nombre d'objets trouvés au départ (@objects_found)
    # alors c'est qu'on a trouvé au moins un objet remplissant les
    # conditions.
    # 
    count_is_right = @objects_found.count == good_objects.count
    error_msg = nil
    unless count_is_right
      diff_regstr = @objects_found.keys - good_objects.keys
      error_msg = concocte_at_error(bad_objects, diff_regstr)
    end
    assert(count_is_right, error_msg)

    #
    # Si un nombre précis est défini, il faut le trouver pour chaque
    # texte/image/graphic/etc. fourni
    # 
    if count?
      good_objects.each do |regstr, objects|
        has_expected_count = expected_count == objects.count
        next if has_expected_count
        error_msg = ERRORS[:failures][:objects_founds_but_not_count] % [expected_count, objects.count]
        assert(has_expected_count, error_msg)
      end
    end
  end

  # def close_to(arg1, arg2 = nil)
  #   self.at(arg1, arg2, delta = 2)
  # end
  # def near_to(arg1, arg2 = nil)
  #   self.at(arg1, arg2, delta = TextObjectMatcher::COORDONNATE_TOLERANCE)
  # end

  private

    ##
    # Concocte error message
    # 
    # @param [Hash<String => Object>] bad_objects
    # @param [Array<String>] missing_regstrs Text which not match coordonates
    def concocte_at_error(bad_objects, missing_regstrs)
      missing_regstrs.map do |regstr|
        bad_objects[regstr].map do |object|
          object.matcher.error_message(regstr)
        end.join("\n")
      end.join("\n")
    end

    def get_coordonates_to_check(arg1, arg2)
      coors = {top: nil, left: nil, right: nil, bottom: nil, width: nil, height: nil}
      # 
      # On met les valeurs à trouver dans la table
      # 
      case arg1
      when Array then coors.merge!(left: arg1[0], top: arg1[1])
      when Hash  then coors.merge!(arg1)
      when Numeric
        case arg2
        when Hash
          coors.merge!(arg2)
          coors.merge!(top: arg1)
        when Numeric  then coors.merge!(left: arg1, top: arg2)
        when NilClass then coors.merge!(top: arg1)
        else raise(ERRORS[:systemic][:dont_know_how_to_deal_with_coor] % "#{arg2.class}")
        end
      else raise(ERRORS[:systemic][:dont_know_how_to_deal_with_coor] % "#{arg1.class}")
      end
      return coors.compact
    end
end #/class NegAssertion
end #/class Checker
end #/module PDF
