class Card
  attr_accessor :id, :elements

  def initialize(attrs = {})
    @id = attrs[:id] || SecureRandom.uuid
    @elements = if attrs[:elements]
                  if attrs[:elements].first.is_a?(Hash)
                    attrs[:elements].map do |elem_attrs|
                      constantize(elem_attrs['type'].to_s.capitalize).new elem_attrs
                    end
                  else
                    attrs[:elements]
                  end
                else
                  []
                end
  end

  def to_h
    {
      id: id,
      elements: elements.map(&:to_h)
    }
  end
end
