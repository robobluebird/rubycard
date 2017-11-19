require './lib/cool_extensions'
require './lib/cool_element'
require './lib/stack'
require './lib/card'
require './lib/field'
require './lib/button'
require './lib/image'
require './lib/cool_button'
require './lib/cool_field'
require './lib/cool_image'
require './lib/cool_listener'
require 'json'
require 'securerandom'

Shoes.app title: 'rubycard', width: 632, height: 512, resizable: false, scroll: false do
  background white

  @current_tool = :hand
  @element = nil
  @gesture = false
  @left_offset = nil
  @top_offset = nil

  def unfocus_all!
    gui.shell.force_focus
  end

  def card_element(id)
    index = @current_card.contents.index { |elem| elem.id == id }
    @current_card.contents[index] if index
  end

  def element_named(name)
    @current_card.contents.detect { |e| e.respond_to?(:name) && e.name == name }
  end

  def delete_element(element)
    element.remove
    save!
    unfocus_all!
  end

  def correct_tool_for?(element)
    @current_tool == element.class.to_s.underscore.split('_').last.to_sym ||
      element.is_a?(CoolImage)
  end

  def assign_element(left, top)
    return if @current_card.nil?

    @current_card.contents.each do |elem|
      next unless elem.is_a?(CoolElement) && interaction_type(elem, left, top)

      @element = elem
      @left_offset = left - @element.left
      @top_offset = top - @element.top
    end
  end

  def interaction_type(elem, left, top)
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
      @interaction_type = :resize
    elsif found_left == 1 && found_top == 1
      @interaction_type = :move
    end
  end

  # EVENTS

  keypress do |key|
    if key == :backspace && @selected
      delete_element @selected
      @selected = nil
    end
  end

  motion do |left, top|
    if @element
      @gesture = true

      if correct_tool_for? @element
        if @interaction_type == :move
          new_left = left - @left_offset
          new_top = top - @top_offset

          new_left = if new_left < 0
                       0
                     elsif new_left + @element.width >= @card_holder.width
                       @card_holder.width - @element.width
                     else
                       new_left
                     end

          new_top = if new_top < 0
                      0
                    elsif new_top + @element.height >= @card_holder.height
                      @card_holder.height - @element.height
                    else
                      new_top
                    end

          @element.move new_left, new_top
        elsif @interaction_type == :resize
          new_width = left - @element.left
          new_height = top - @element.top

          new_width = if new_width < 20
                        20
                      elsif @element.left + new_width >= @card_holder.width
                        @card_holder.width - @element.left
                      else
                        new_width
                      end

          new_height = if new_height < 20
                         20
                       elsif @element.top + new_height >= @card_holder.height
                         @card_holder.height - @element.top
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

    @element_to_modify = @element

    if @element && correct_tool_for?(@element)
      if @element.is_a? CoolImage
        window title: 'edit image', width: 400, height: 300 do
          background lightgrey

          @element = owner.instance_variable_get(:@element)

          stack margin: 5 do
            caption 'name'
            @edit_name = edit_line @element.name

            caption 'script'
            @edit_script = edit_box @element.script, width: 390, height: 200

            flow do
              button 'cancel' do
                close
              end

              button 'save' do
                owner.set_image_properties(@edit_name.text, @edit_script.text)
                close
              end
            end
          end
        end
      elsif @element.is_a? CoolButton
        window title: 'edit button', width: 400, height: 500 do
          background lightgrey

          @element = owner.instance_variable_get(:@element)

          stack margin: 5 do
            caption 'name'
            @edit_name = edit_line @element.name

            caption 'title'
            @edit_title = edit_line @element.title

            caption 'style'
            @list_box = list_box items: ['shadow', 'plain', 'transparent']
            @list_box.choose @element.button_style.to_s

            caption 'font size'
            @edit_font_size = edit_line @element.font_size.to_s

            caption 'script'
            @edit_script = edit_box @element.script, width: 390, height: 200

            flow do
              button 'cancel' do
                close
              end

              button 'save' do
                owner.set_button_properties(
                  @edit_name.text,
                  @edit_title.text,
                  @list_box.text.to_sym,
                  @edit_font_size.text.to_i,
                  @edit_script.text
                )

                close
              end
            end
          end
        end
      elsif @element.is_a? CoolField
        window title: 'edit field', width: 300, height: 300 do
          background lightgrey

          @element = owner.instance_variable_get(:@element)

          stack margin: 5 do
            caption 'name'
            @edit_name = edit_line @element.name

            caption 'text'
            @edit_text = edit_box @element.text

            flow do
              @lock_text = check; para 'lock text?'
              @lock_text.checked = @element.locked?
            end

            flow do
              @hide_border = check; para 'hide border?'
              @hide_border.checked = @element.hide_border
            end

            caption 'font size'
            @edit_font_size = edit_line @element.font_size.to_s

            flow do
              button 'cancel' do
                close
              end

              button 'save' do
                owner.set_field_properties(
                  @edit_name.text,
                  @edit_text.text,
                  @lock_text.checked?,
                  @hide_border.checked?,
                  @edit_font_size.text.to_i
                )

                close
              end
            end
          end
        end
      end
    end

    @element = nil
    @gesture = false
    @interaction_type = nil
    @left_offset = nil
    @top_offset = nil
  end

  def set_button_properties(name, title, button_style, font_size, script)
    @element_to_modify.set_button_style button_style
    @element_to_modify.set_font_size font_size
    @element_to_modify.set_title title
    @element_to_modify.name = name
    @element_to_modify.script = script
    @element_to_modify.style
    @element_to_modify = nil

    save!
  end

  def set_field_properties(name, text, lock_text, hide_border, font_size)
    @element_to_modify.set_text text
    @element_to_modify.set_hide_border hide_border
    @element_to_modify.set_font_size font_size
    @element_to_modify.locked = lock_text
    @element_to_modify.name = name
    @element_to_modify.style
    @element_to_modify = nil

    save!
  end

  def set_image_properties(name, script)
    @element_to_modify.name = name
    @element_to_modify.script = script
    @element_to_modify = nil

    save!
  end

  release do |button, left, top|
    if @element
      if !@gesture
        if @current_tool == :hand
          if @element.respond_to?(:script) && !@element.script.nil?
            instance_eval @element.script
          elsif @element.respond_to?(:editable=) && @element.respond_to?(:locked?)
            @element.editable = true unless @element.locked?
          end

          make_fields_uneditable!
        elsif correct_tool_for? @element
          select @element
        end
      else
        select @element if @element != @selected && correct_tool_for?(@element)
        save!
      end
    else
      make_fields_uneditable!
      deselect!
    end

    @element = nil
    @gesture = false
    @interaction_type = nil
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
    return if @current_card.nil?

    @current_card.contents.each do |elem|
      elem.editable = false if elem.respond_to?(:editable=) && elem != @element
    end
  end

  def select(element)
    @selected.deselect if @selected
    @selected = element
    @selected.select
  end

  def deselect!
    return unless @selected
    @selected.deselect
    @selected = nil
  end

  def load!(json)
    @current_stack = Stack.new path: json['path'], name: json['name']
    @current_card_index = 0

    json['cards'].each do |card_json|
      @current_stack.cards.push Card.new id: card_json['id'], elements: card_json['elements']
    end

    represent!

    @stack_related_stuff.show
  end

  def save!
    elements = []

    @current_card.contents.each do |elem|
      if elem.is_a? CoolElement
        elements.push constantize(elem.opts['type'].to_s.capitalize).new elem.opts
      end
    end

    @current_stack.cards[@current_card_index].elements = elements

    File.open(@current_stack.path, 'w+') do |f|
      f.write JSON.pretty_generate(@current_stack.to_h)
    end
  end

  def represent!
    @card_holder.clear do
      @current_card = stack top: 0, left: 0, height: '100%', width: '100%' do
        background white

        @current_stack.cards[@current_card_index].elements.each do |elem|
          self.send(elem.method_sym, elem.opts)
        end

        unfocus_all!
      end

      @card_info.text = "#{@current_card_index + 1}/#{@current_stack.cards.count}"
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

  def delete_card!
    if @current_stack.cards.count > 1
      @current_stack.cards.delete_at @current_card_index

      while @current_card_index >= @current_stack.cards.count
        @current_card_index -= 1
      end

      represent!
      save!
    end
  end

  def default!
    stack left: 0, top: 0, width: 512, height: '100%'  do
      t = title 'rubycard', align: 'center'
      t.style top: height / 2 - t.height / 2
    end
  end

  def select_tool(tool)
    return if @current_card.nil?

    @current_tool = tool
    @hand.path = 'lib/images/handlight.png'
    @buttons.path = 'lib/images/buttonlight.png'
    @fields.path = 'lib/images/fieldlight.png'
    @paint.path = 'lib/images/brushlight.png'

    if tool == :hand
      @hand.path = 'lib/images/handdark.png'
    elsif tool == :button
      @buttons.path = 'lib/images/buttondark.png'
    elsif tool == :field
      @fields.path = 'lib/images/fielddark.png'
    elsif tool == :paint
      @paint.path = 'lib/images/brushdark.png'
    end
  end

  flow top: 0, left: 0, width: '100%', height: '100%' do
    background white

    @card_holder = default!

    stack top: 0, left: 512, width: 120, height: '100%' do
      background lightgrey

      @stack_related_stuff = stack do
        flow margin: 5, height: 84 do
          background black

          @hand = image 'lib/images/handdark.png', width: 34, height: 34, left: 2, top: 2
          @buttons = image 'lib/images/buttonlight.png', width: 34, height: 34, left: 38, top: 2
          @fields = image 'lib/images/fieldlight.png', width: 34, height: 34, left: 74, top: 2
          @paint = image 'lib/images/brushlight.png', width: 34, height: 34, left: 2, top: 38

          block_out = rect 38, 38, 70, 34
          block_out.style fill: white, stroke: white

          @hand.click = -> (i) { select_tool :hand }
          @buttons.click = -> (i) { select_tool :button }
          @fields.click = -> (i) { select_tool :field }
          @paint.click = -> (i) { alert "I'm really sorry Rubyconf, there wasn't enough time to do this!" }
        end

        stack do
          @card_info = para '', align: 'center'

          button 'new button' do
            @current_card.append do
              cool_button
            end

            save!
          end

          button 'new field' do
            @current_card.append do
              cool_field
            end

            save!
          end

          button 'new image' do
            filename = ask_open_file

            if filename
              @current_card.append do
                cool_image path: filename
              end

              save!
            end
          end

          button 'next card' do
            next_card!
          end

          button 'previous card' do
            prev_card!
          end

          button 'delete card' do
            delete_card!
          end

          button 'new blank' do
            @current_stack.cards.push Card.new
            @current_card_index = @current_stack.cards.count - 1

            represent!
            save!
          end

          button 'new copy' do
            dup = @current_stack.cards[@current_card_index].dup

            @current_stack.cards.push dup
            @current_card_index = @current_stack.cards.count - 1

            represent!
            save!
          end
        end
      end

      @stack_related_stuff.hide

      @general_purpose_buttons = stack do
        button 'new stack' do
          filename = ask_save_file

          if filename
            if File.exist? filename
              alert "Stack with name \"#{filename.split('/').last}\" already exists!"
            else
              @current_stack = Stack.new path: filename
              @current_stack.cards.push Card.new
              @current_card_index = 0

              represent!
              save!

              @stack_related_stuff.show
            end
          end
        end

        button 'open stack' do
          filename = ask_open_file

          if filename
            File.open(filename, 'r') do |f|
              begin
                load! JSON.parse f.read.strip
              rescue => e
                alert "failed to understand the file: #{e}"
              end
            end
          end
        end

        button 'quit' do
          quit
        end
      end
    end
  end
end
