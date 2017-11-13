class Stack
  attr_accessor :name, :id, :cards

  def initialize(attrs = {})
    @id = attrs[:id]
    @name = attrs[:name]
    @cards = attrs[:cards] || []
  end
end
