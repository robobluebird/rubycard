class Stack
  attr_accessor :path, :name, :cards

  def initialize(attrs = {})
    @path = attrs[:path]
    @name = attrs[:name] || attrs[:path].split('/').last
    @cards = attrs[:cards] || []
  end

  def to_h
    {
      path: path,
      name: name,
      cards: cards.map(&:to_h)
    }
  end
end
