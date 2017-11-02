class Shoes
  module Swt
    class EditBox
      ALT_DEFAULT_STYLES = ::Swt::SWT::MULTI | ::Swt::SWT::WRAP | ::Swt::SWT::V_SCROLL

      def resize
        @real.set_size @dsl.element_width, @dsl.element_height
      end

      def change_font_size(font_size)

      end

      def initialize(dsl, app)
        super(dsl, app, ALT_DEFAULT_STYLES)
      end
    end
  end

  class App
    def set_location(left, top)
      gui.shell.set_location(left, top)
    end

    def x
      gui.shell.get_location.x
    end

    def y
      gui.shell.get_location.y
    end
  end
end
