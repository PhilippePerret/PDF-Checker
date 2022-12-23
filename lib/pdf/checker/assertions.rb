module PDF
class Checker

  # @return [Boolean] true if PDF document includes +searched+
  # 
  # @example
  #   checker.include?("My string")
  #   checker.include?({string:"Word", before:"Hello"})
  # 
  # @param [String|Array|Hash]
  # 
  def include?(searched)
    case searched
    when String
      return plain_text.index(searched) != nil
    when Regexp
      return !!plain_text.match?(searched)
    when Array
      searched.each do |foo|
        return false unless include?(foo)
      end
    when Hash
      searched.key?(:string) || raise("#include? with Hash required a :string key ()")
      str = searched[:string]
      return false unless include?(str)
      if searched.key?(:after) || searched.key?(:before)
        str_aft = searched[:after]
        str_bef = searched[:before]
        offsets = strings_with_offsets([str, str_aft, str_bef])
        off_str = offsets[str]
        off_aft = offsets[str_aft]
        off_bef = offsets[str_bef]
        return false if str_aft && off_aft > off_str
        return false if str_bef && off_bef < off_str
      end

      # Il y aura d'autres vérifications ici, par exemple after:'other mot', before:'other mot'
    end
    return true
  end


  # @return [Hash<String => Integer>] First indexes of each +strs+ in
  # document.
  # @param [Array] strs List of strings
  def strings_with_offsets(strs)
    indexes = {}
    strs.each do |str|
      next if str.nil?
      indexes.merge!( str => plain_text.index(str))
    end
    return indexes
  end

end #/class Checker
end #/module PDF
