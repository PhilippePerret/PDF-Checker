class Integer

  def pages
    return {count: self.freeze, type: :page}
  end
  alias :page :pages

  def images
    return {count: self.freeze, type: :image}
  end
  alias :image :images

  def graphics
    return {count: self.freeze, type: :graphic}
  end
  alias :graphic :graphics
end
