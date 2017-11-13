require './lib/cool_extensions'
require './lib/cool_element'
require './lib/stack'
require './lib/card'
require './lib/field'
require './lib/button'
require './lib/cool_card'
require './lib/cool_button'
require './lib/cool_field'
require './lib/cool_popup'
require './lib/cool_listener'
require 'json'

Shoes.app title: 'rubycard', width: 512, height: 346, resizable: false, scroll: false do
  background white

  # @user_levels = { 1: 'browsing', 2: 'typing', 3: 'painting', 4: 'authoring', 5: 'scripting' }

  @protection_types = [
    "can't modify stack",
    "can't delete stack",
    "can't abort",
    "can't peek",
    "private access"
  ]

  @current_tool = :hand
  @current_user_level = 5

  # @user_level_adjuster = window do
  #   para 'meh'
  # end

  @tools = window title: '', width: 120, height: 240, top: 500, left: 500 do
    flow margin: 5, height: 48 do
      background black

      @hand = image 'lib/images/handdark.png', width: 34, height: 34, left: 2, top: 2
      @buttons = image 'lib/images/buttonlight.png', width: 34, height: 34, left: 38, top: 2
      @fields = image 'lib/images/fieldlight.png', width: 34, height: 34, left: 74, top: 2

      @hand.click = -> (i) { select_tool :hand }
      @buttons.click = -> (i) { select_tool :button }
      @fields.click = -> (i) { select_tool :field }
    end

    def select_tool(tool)
      owner.current_tool = tool

      @hand.path = 'lib/images/handlight.png'
      @buttons.path = 'lib/images/buttonlight.png'
      @fields.path = 'lib/images/fieldlight.png'

      if tool == :hand
        @hand.path = 'lib/images/handdark.png'
      elsif tool == :button
        @buttons.path = 'lib/images/buttondark.png'
      elsif tool == :field
        @fields.path = 'lib/images/fielddark.png'
      end
    end
  end

  @tools.set_location(x + width, y)
  @tools.gui.shell.force_active
  gui.shell.force_active

  def unfocus_all
    gui.shell.force_focus
  end

  def card_element(id)
    index = @current_card.contents.index { |elem| elem.id == id }
    @current_card.contents[index] if index
  end

  def save!
    to_save = {
      name: @current_stack.name,
      id: @current_stack.id,
      cards: []
    }

    @current_stack.cards.each do |c|
      to_save[:cards].push(
        id: c.id,
        elements: c.rep.contents.map { |e| e.to_dsl_str }
      )
    end
  end

  # @current_card = stack do
  #   @field = cool_field text: 'first'
  #   @field2 = cool_field text: 'second'
  #   @button = cool_button text: 'putsing'
  #   @button2 = cool_button text: 'change button type'
  #   @button3 = cool_button text: 'increase button font size'
  #   @button4 = cool_button text: 'bring field to front', top: 200, left: 50
  #   @button.id = 1
  #   @button2.id = 2
  #   @button3.id = 3
  #   @button4.id = 4
  #   @field2 = cool_field text: 'second'
  #   @field2.id = 6
  #   @field.id = 5
  #   @button2.code = "@button.toggle_button_type"
  #   @button3.code = "@button.increase_font_size"
  #   @button4.code = "puts 'hi!'; @field2.java_text_widget.move_below(@field.java_text_widget)"
  #   unfocus_all
  # end

  # def reverse_field_order!
  #   cool_fields_in_wrong_order = @current_card.contents.reject { |c| c.is_a? CoolField }
  #   real_fields_in_wrong_order = cool_fields_in_wrong_order.map { |f| f.gui.real }
  # end
  #
  # reverse_field_order!

  @element = nil
  @gesture = false
  @left_offset = nil
  @top_offset = nil

  def correct_tool_for?(element)
    @current_tool == element.class.to_s.underscore.split('_').last.to_sym
  end

  def assign_element(left, top)
    @current_card.contents.each do |elem|
      next unless elem.is_a?(CoolElement) && modification_type(elem, left, top)

      @element = elem
      @left_offset = left - @element.left
      @top_offset = top - @element.top
    end
  end

  def modification_type(elem, left, top)
    left_ranges = [
      (elem.left + elem.width - 10)..(elem.left + elem.width),
      elem.left..(elem.left + elem.width)
    ]

    top_ranges = [
      (elem.top + elem.height - 10)..(elem.top + elem.height),
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

  keypress do |key|
    puts key
  end

  motion do |left, top|
    if @element
      @gesture = true

      if correct_tool_for? @element
        if @modification_type == :move
          new_left = left - @left_offset
          new_top = top - @top_offset

          new_left = if new_left < 0
                       0
                     elsif new_left + @element.width >= width
                       width - @element.width
                     else
                       new_left
                     end

          new_top = if new_top < 0
                      0
                    elsif new_top + @element.height >= height
                      height - @element.height
                    else
                      new_top
                    end

          @element.move new_left, new_top
        elsif @modification_type == :resize
          new_width = left - @element.left
          new_height = top - @element.top

          new_width = if new_width < 20
                        20
                      elsif @element.left + new_width >= width
                        width - @element.left
                      else
                        new_width
                      end

          new_height = if new_height < 20
                         20
                       elsif @element.top + new_height >= height
                         height - @element.top
                       else
                         new_height
                       end

          @element.style width: new_width, height: new_height
        end
      end
    end
  end

  click do |button, left, top|
    assign_element left, top
  end

  double_click do |button, left, top|
    assign_element left, top

    if @element && correct_tool_for?(@element)
      cool_popup @element
    end

    @element = nil
    @gesture = false
    @modification_type = nil
    @left_offset = nil
    @top_offset = nil
  end

  release do |button, left, top|
    if @element
      if !@gesture
        if @current_tool == :hand
          if @element.respond_to?(:code) && !@element.code.nil?
            instance_eval @element.code
          elsif @element.respond_to? :editable=
            @element.editable = true
          end

          make_fields_uneditable!
        elsif correct_tool_for? @element
          select @element
        end
      else
        select @element if @element != @selected_element && correct_tool_for?(@element)
      end
    else
      make_fields_uneditable!
      deselect!
    end

    @element = nil
    @gesture = false
    @modification_type = nil
    @left_offset = nil
    @top_offset = nil
  end

  def current_tool=(tool)
    if [:hand, :button, :field].include?(tool) && @current_tool != tool
      make_fields_uneditable!
      deselect!
      @current_tool = tool
    end
  end

  def current_tool
    @current_tool
  end

  def make_fields_uneditable!
    @current_card.contents.each do |elem|
      elem.editable = false if elem.respond_to?(:editable=) && elem != @element
    end
  end

  def select(element)
    @selected.deselect if @selected
    element.select
    @selected = element
  end

  def deselect!
    return unless @selected
    @selected.deselect
    @selected = nil
  end

  def load!(json)
    @current_stack = Stack.new name: json['name']
    @current_card_index = 0

    json['cards'].each do |card_json|
      @current_stack.cards.push Card.new elements: card_json['elements']
    end

    represent!
  end

  def represent!
    @current_card = clear do
      background white

      @current_stack.cards[@current_card_index].elements.each do |elem|
        self.send(elem.method_sym, elem.opts)
      end
    end
  end

  def next_card!
    if @current_stack.cards.count - 1 > @current_card_index
      @current_card_index += 1
      represent!
    end
  end

  def prev_card!
    if @current_card_index > 0
      @current_card_index -= 1
      represent!
    end
  end

  def save!
  end

  load!(
    JSON.parse({
      name: 'a cool stack',
      id: 1,
      cards: [
        {
          elements: [
            {
              type: 'field',
              text: 'a fun paragraph about horses',
              hide_border: true
            },
            {
              type: 'button',
              top: 300,
              left: 400,
              text: 'next card',
              code: 'next_card!'
            }
          ]
        },
        {
          elements: [
            {
              type: 'button',
              text: 'previous card',
              top: 300,
              left: 20,
              code: 'prev_card!'
            },
            {
              type: 'field',
              text: 'crazy days',
              hide_border: true,
              font_size: 40
            },
          ]
        }
      ]
    }.to_json)
  )
end
