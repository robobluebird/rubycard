class Stack
  attr_accessor :name, :cards

  def initialize(attrs = {})
    @name = attrs[:name]
    @cards = attrs[:cards] || []
  end

  def to_h
    {
      name: name,
      cards: cards.map(&:to_h)
    }
  end
end
