require_relative 'assertion'
module PDF
class Checker
class TextAssertion < PDF::Checker::Assertion

  ##
  # --- Analyse ---
  # 
  # @searched contient les strings ou les regexp à trouver dans 
  # le propriétaire (@owner) de cette assertion.
  def proceed
    # 
    # On met le texte cherché dans une liste si c'est un texte ou
    # une expression régulière seule
    # 
    @searched = [searched] unless searched.is_a?(Array)
    # 
    # Table pour mettre les objets-textes trouvés
    # @note
    #   'tof' pour Text-Object-Found (TOF)
    # 
    tof = {}
    # 
    # Table pour mettre les textes non trouvés
    # @note
    #   'bof' pour Bad-Object-Found
    bof = {}
    # 
    # Boucle sur tous les objets textuels (on fait un matcher par
    # objet)
    # 
    owner.texts_objects.each do |text_object|
      # 
      # On crée un matcher pour ce texte-objet
      # 
      matcher = PDF::Checker::TextObjectMatcher.new(text_object, options)
      # 
      # On attache ce matcher au texte-objet
      # 
      text_object.matcher = matcher
      # 
      # Boucle sur tous les textes cherchés pour savoir si 
      # l'objet texte les contient.
      # 
      searched.each do |regstr|
        # 
        # On regarde si ce matcher contient (ou ne contient pas) ce
        # texte|regexp cherché. Si c'est le cas, on ajoute ce texte
        # trouvé à +tof+ s'il ne connait pas encore
        # ce texte, et on ajoute l'objet à la liste des objets
        # possibles (pour pouvoir ensuite checker les propriétés)
        # 
        ok = matcher.does_or_neg_contains?(regstr)
        liste = ok ? tof : bof
        liste.key?(regstr) || liste.merge!(regstr => [])
        liste[regstr] << text_object
      end #/fin boucle sur tous les textes|regexp cherchés
    end

    # 
    # Dans tous les cas, on doit avoir autant de réussite que
    # de textes recherchés (ou non)
    count_is_right = searched.count == tof.count
    err_msg = nil
    unless count_is_right
      # diff_regstrs = (searched - tof.keys).map{|s|s.inspect}.pretty_join
      diff_regstrs = bof.keys.map{|s|s.inspect}.pretty_join
      err_msg = "Les textes suivants n'ont pas été trouvés : #{diff_regstrs}"
    end
    assert(count_is_right, err_msg)


    if expected_count
      # 
      # Si un nombre exact est demandé, on doit l'avoir trouvé
      # pour chacun des textes cherchés (en général un seul dans
      # ce cas)
      # 
      tof.each do |regstr, text_objects|
        assert_equal(expected_count, text_objects.count)
      end
    end
    # 
    # Pour passer à la suite
    # 
    @objects_found = tof
  end
  #/ #proceed


  ##
  # Quand with_properties (ou with) est chainé à has_text
  # 
  # @param [Hash] properties Les propriétés attendues
  # 
  def with_properties(**properties)
    #
    # Si un nombre précis est attendu
    # 
    count_expected = properties.delete(:count)
    #
    # Pour simplifier le code
    #
    tof = @objects_found
    # 
    # Pour mettre les nouveaux texte-objets qui passeront le
    # test courant
    # 
    new_tof = {}
    # 
    # Pour mettre les mauvais texte-objets (qui ne passeront pas
    # les tests courants)
    # 
    bad_tof = {}
    # 
    # Boucle sur tous les texte-objets trouvés
    # 
    @objects_found.each do |regstr, text_objects|
      text_objects.each do |text_object|
        # 
        # Si le text-object possède les propriétés voulues, on
        # le consigne. Sinon, on le met dans la liste des mauvais
        # textes-objets pour un message d'erreur détaillé
        # 
        if text_object.matcher.has_properties?(**properties)
          new_tof.merge!(regstr => []) unless new_tof.key?(regstr)
          new_tof[regstr] << text_object
        else
          bad_tof.merge!(regstr => []) unless bad_tof.key?(regstr)
          bad_tof[regstr] << text_object
        end
      end
    end #/fin de boucle sur tous les text-objects trouvés

    # 
    # Dans tous les cas, on doit avoir trouvé au moins autant de
    # texte-objets que de textes fournis
    # 
    keys_diff = tof.keys - new_tof.keys
    assert(tof.count == new_tof.count, concocte_error_message(bad_tof, keys_diff))

    # 
    # Quand un nombre précis est attendu
    #
    unless count_expected.nil?
      new_tof.each do |regstr, tos|
        assert_equal(count_expected, tos.count, ERRORS[:failures][:bad_count_with_properties] % {searched: regstr.inspect, expected: count_expected, actual: tos.count})
      end 
    end

    # 
    # On met les textes trouvés dans la liste, pour la liste éventuelle
    # 
    @objects_found = new_tof

  end
  alias :with :with_properties


  private

    def concocte_error_message(bad_tof, regstrs_missing)
      regstrs_missing.map do |regstr|
        bad_tof[regstr].map do |text_object|
          text_object.matcher.error_message(regstr)
        end.join("\n")
      end.join("\n")
    end

end #/class TextAssertion
end #/class Checker
end #/module PDF
