class CoolButton < Shoes::Widget
  attr_accessor :editable, :click_block

  def set_editable(editable)
    @editable = editable
    @edit_border.toggle(editable)
  end

  def style(styles = nil)
    super styles
    @para.style(top: @para.parent.height / 2 - @para.height / 2) if @para
    @style
  end

  def initialize_widget(title, width, height)
    style width: width, height: height

    @stack = stack left: 0, width: '100%', height: '100%' do
      @background = background white, curve: 4, width: '100%', height: '100%'
      @border = border black, curve: 4, strokewidth: 2, width: '100%', height: '100%'
      @para = para title, left: 0, align: 'center', width: '100%'
      @para.style(top: @para.parent.height / 2 - @para.height / 2)
    end

    click { instance_eval(click_block) if click_block }
  end
end

Shoes.app title: 'rubycard', width: 512, height: 346, resizable: false, scroll: false do
  background lime..blue

  @current_card = flow height: '100%', width: '100%' do
    @button = cool_button 'yes', 100, 75
  end

  @element = nil
  @left_offset = nil
  @top_offset = nil

  # TOP-LEVEL METHODS

  def assign_element(left, top)
    @current_card.contents.each do |elem|
      next unless elem.is_a? CoolButton
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

  motion do |left, top|
    if @element
      if @modification_type == :move
        @element.move left - @left_offset, top - @top_offset
      elsif @modification_type == :resize
        new_width = left - @element.left
        new_height = top - @element.top

        new_width = @element.width if new_width <= 20
        new_height = @element.height if new_height <= 20

        @element.style(width: new_width, height: new_height)
      end
    end
  end

  click do |button, left, top|
    assign_element left, top
  end

  release do |button, left, top|
    @element = nil
    @modification_type = nil
    @left_offset = nil
    @top_offset = nil
  end
end
