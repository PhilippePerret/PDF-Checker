class String

  def words
    self
      .gsub(/[\!\?;:\.…\-_–\(\)]/,'')
      .gsub(/  +/,' ')
      .split(' ')
  end

end #/class String
