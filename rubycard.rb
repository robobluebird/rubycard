require './extensions.rb'

class CoolElement < Shoes::Widget; end

class CoolButton < CoolElement
  attr_accessor :code, :card_button_id, :id

  def set_editable(editable)
    @editable = editable
    @edit_border.toggle(editable)
  end

  def style(styles = nil)
    super styles
    @para.style(top: @para.parent.height / 2 - @para.height / 2) if @para
    @style
  end

  def initialize_widget(title: "New Button", width: 100, height: 25)
    style width: width, height: height

    @stack = stack left: 0, width: '100%', height: '100%' do
      @background = background white, curve: 2, width: '100%', height: '100%'
      @border = border black, curve: 2, strokewidth: 1, width: '100%', height: '100%'
      @para = para title, left: 0, align: 'center', width: '100%'
    end
  end
end

class CoolField < CoolElement
  attr_accessor :code, :card_field_id, :id, :edit

  def do_something

  end

  def toggle_edit_state
    new_state = @edit.enabled? ? :disabled : :enabled

    @edit.style state: new_state
  end

  def style(styles = nil)
    super styles

    if @edit
      @edit.style width: @edit.parent.width - 2, height: @edit.parent.height - 2
      @edit.gui.resize
    end

    @style
  end

  def initialize_widget(width: 200, height: 100)
    style width: width, height: height

    @stack = stack left: 0, width: '100%', height: '100%' do
      @background = background white, width: '100%', height: '100%'
      @border = border black, strokewidth: 1
      @edit = edit_box top: 1, left: 1, width: width - 2, height: height - 2, state: :disabled
    end
  end
end

class CoolStack
  attr_accessor :cards, :name

  def initialize(attrs = {})
    @cards = attrs[:cards] || []
  end
end

class CoolCard
  attr_accessor :id, :elements

  def initialize(attrs = {})
  end

  def render
  end
end

Shoes.app title: 'rubycard', width: 512, height: 346, resizable: false, scroll: false do
  @weird = window title: 'tools', width: 120, height: 240, top: 500, left: 500 do
    button 'yes' do
      alert 'hi!'
    end
  end

  @weird.set_location(x + width, y)

  def card_element(id)
    index = @current_card.contents.index { |elem| elem.id == id }

    @current_card.contents[index] if index
  end

  @current_card = flow height: '100%', width: '100%' do
    @button = cool_button
    @button2 = cool_button title: "move window"
    @button.id = 1
    @button2.id = 2
    @field = cool_field
    @field.id = 3
    @button.code = -> { card_element(3).toggle_edit_state  }
    @button2.code = -> { @weird.set_location(0, 0) }
  end

  @element = nil
  @gesture = false
  @left_offset = nil
  @top_offset = nil

  # TOP-LEVEL METHODS

  def assign_element(left, top)
    @current_card.contents.each do |elem|
      next unless elem.is_a? CoolElement
      next if modification_type(elem, left, top).nil?

      @element = elem
      @left_offset = left - @element.left
      @top_offset = top - @element.top
    end
  end

  def modification_type(elem, left, top)
    left_ranges = [
      (elem.left + elem.width - 5)..(elem.left + elem.width),
      elem.left..(elem.left + elem.width)
    ]

    top_ranges = [
      (elem.top + elem.height - 5)..(elem.top + elem.height),
      elem.top..(elem.top + elem.height)
    ]

    found_left = left_ranges.index { |range| range.cover? left }
    found_top = top_ranges.index { |range| range.cover? top }

    if (found_left == 0 && found_top == 0)
      @modification_type = :resize
    elsif found_left == 1 && found_top == 1
      @modification_type = :move
    end
  end

  # EVENTS

  # @flap = 0.1

  motion do |left, top|
    if @element
      @gesture = true

      if @modification_type == :move
        @element.move left - @left_offset, top - @top_offset
      elsif @modification_type == :resize
        new_width = left - @element.left
        new_height = top - @element.top

        new_width = @element.width if new_width <= 20
        new_height = @element.height if new_height <= 20

        @element.style width: new_width, height: new_height
      end
    end
  end

  click do |button, left, top|
    assign_element left, top
  end

  release do |button, left, top|
    @element.code.call if @element && !@gesture && @element.respond_to?(:code) && !@element.code.nil?

    # if @gesture && @modification_type == :resize && @element.is_a?(CoolField)
    #   @element.move @element.left.floor, @element.top.floor
    #   puts "#{@element.left} something #{@element.top}"
    # end

    @element = nil
    @gesture = false
    @modification_type = nil
    @left_offset = nil
    @top_offset = nil
  end
end
