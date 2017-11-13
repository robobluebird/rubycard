class Card
  attr_accessor :name, :id, :elements, :rep

  def initialize(attrs = {})
    @name = attrs[:name]
    @id = attrs[:id]
    @elements = attrs[:elements].map do |elem_attrs|
      constantize(elem_attrs['type'].to_s.capitalize).new elem_attrs
    end
  end
end
