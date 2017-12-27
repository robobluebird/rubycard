class String
  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
end

# File activesupport/lib/active_support/inflector/methods.rb, line 258
def constantize(camel_cased_word)
  names = camel_cased_word.split("::".freeze)

  # Trigger a built-in NameError exception including the ill-formed constant in the message.
  Object.const_get(camel_cased_word) if names.empty?

  # Remove the first blank element in case of '::ClassName' notation.
  names.shift if names.size > 1 && names.first.empty?

  names.inject(Object) do |constant, name|
    if constant == Object
      constant.const_get(name)
    else
      candidate = constant.const_get(name)
      next candidate if constant.const_defined?(name, false)
      next candidate unless Object.const_defined?(name)

      # Go down the ancestors to check if it is owned directly. The check
      # stops when we reach Object or the end of ancestors tree.
      constant = constant.ancestors.inject(constant) do |const, ancestor|
        break const    if ancestor == Object
        break ancestor if ancestor.const_defined?(name, false)
        const
      end

      # owner is in Object, so raise
      constant.const_get(name, false)
    end
  end
end

class Shoes
  class Border
    style_with :angle, :common_styles, :curve, :dimensions, :stroke, :strokewidth, :linestyle
    STYLES = { angle: 0, curve: 0, linestyle: :solid }.freeze
  end

  module Swt
    ICON = 'lib/images/bill.png'

    class TextBlock
      class CursorPainter
        def draw_textcursor
          segment = @collection.segment_at_text_position(@text_block_dsl.cursor)
          relative_cursor = @collection.relative_text_position(@text_block_dsl.cursor)
          position = segment.get_location(relative_cursor)
          #
          # if @text_block_dsl.text[-1] == "\n"
          #   count = 0
          #   idx = -1
          #
          #   while @text_block_dsl.text[idx] == "\n"
          #     count += 1
          #     idx -= 1
          #   end
          #
          #   move_if_necessary(segment.element_left,
          #     segment.element_top + position.y + (textcursor.height * count))
          # else
          #   move_if_necessary(segment.element_left + position.x,
          #                     segment.element_top + position.y)
          # end

          move_if_necessary(segment.element_left + position.x,
                            segment.element_top + position.y)
        end

        def move_if_necessary(x, y)
          unless textcursor.left == x && textcursor.top == y
            move_textcursor(x, y)
          end
        end
      end
    end

    class Border
      class Painter
        def draw_setup(gc)
          line_style = case @obj.dsl.style[:linestyle]
                       when :solid
                         ::Swt::SWT::LINE_SOLID
                       when :dot
                         ::Swt::SWT::LINE_DOT
                       when :dash
                         ::Swt::SWT::LINE_DASH
                       when :dashdot
                         ::Swt::SWT::LINE_DASHDOT
                       when :dashdotdot
                         ::Swt::SWT::LINE_DASHDOTDOT
                       else
                         ::Swt::SWT::LINE_SOLID
                       end

          gc.set_line_style line_style

          @obj.apply_stroke gc

          true
        end
      end
    end

    class EditBox
      ALT_DEFAULT_STYLES = ::Swt::SWT::MULTI | ::Swt::SWT::WRAP | ::Swt::SWT::V_SCROLL

      def resize
        @real.set_size @dsl.element_width, @dsl.element_height
      end

      def initialize(dsl, app)
        super(dsl, app, ALT_DEFAULT_STYLES)
      end
    end

    class App
      def double_click(block)
        app.click_listener.add_double_click_listener(dsl, block)
      end
    end
  end

  class App
    def double_click(&block)
      gui.double_click(block)
      self
    end

    def set_location(left, top)
      gui.shell.set_location(left, top)
    end

    def x
      gui.shell.get_location.x
    end

    def y
      gui.shell.get_location.y
    end

    class MouseListener
      def mouseDoubleClick(e)
        @app.dsl.mouse_button = e.button
        @app.dsl.mouse_pos = [e.x, e.y]
      end
    end
  end
end

class Shoes
  module Swt
    class ClickListener
      def initialize(swt_app)
        @clickable_elements = []
        @clicks        = {}
        @double_clicks = {}
        @releases      = {}
        swt_app.add_listener ::Swt::SWT::MouseDown, self
        swt_app.add_listener ::Swt::SWT::MouseUp, self
        swt_app.add_listener ::Swt::SWT::MouseDoubleClick, self
      end

      def add_double_click_listener(dsl, block)
        add_clickable_element(dsl)
        @double_clicks[dsl] = block
      end

      def remove_listeners_for(dsl)
        @clickable_elements.delete(dsl)
        @clicks.delete(dsl)
        @double_clicks.delete(dsl)
        @releases.delete(dsl)
      end

      def handle_event(event)
        handlers = case event.type
                   when ::Swt::SWT::MouseDown        then @clicks
                   when ::Swt::SWT::MouseUp          then @releases
                   when ::Swt::SWT::MouseDoubleClick then @double_clicks
                   end

        return if handlers.nil? || handlers.empty?

        handlers = handlers.to_a
                           .reject { |dsl, _| dsl.hidden? }
                           .select { |dsl, _| dsl.in_bounds?(event.x, event.y) }

        dsl, block = handlers.last

        eval_block(event, dsl, block)
      end
    end
  end
end
