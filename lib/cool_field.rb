class CoolField < CoolElement
  attr_accessor :code, :card_field_id, :id
  attr_reader :java_text_widget, :font_size

  def self.dsl(opts = {})
    "cool_field #{opts[:text]}, width: #{opts[:width]}, \
      height: #{opts[:height]}, font_size: #{opts[:font_size]}"
  end

  def text
    @words.text
  end

  def increase_font_size
    @font_size += 4
    font_size!
  end

  def decrease_font_size
    @font_size -= 4
    font_size!
  end

  def font_size!
    original_font = @java_text_widget.get_font
    font_data = original_font.get_font_data
    font_data.each { |f| f.set_height @font_size }
    new_font = ::Swt::Font.new(::Swt.display, font_data)
    @java_text_widget.set_font new_font
  end

  def editable=(editable)
    @java_text_widget.set_editable editable
  end

  def style(styles = nil)
    super styles

    if @words
      @words.style width: @words.parent.width - 2, height: @words.parent.height - 2
      @words.gui.resize
    end

    @app.gui.redraw

    @style
  end

  def initialize_widget(opts = {})
    style_opts = { width: opts[:width] || 200, height: opts[:height] || 100 }
    style_opts[:left] = opts[:left] || @app.width / 2 - style_opts[:width] / 2
    style_opts[:top] = opts[:top] || @app.height / 2 - style_opts[:height] / 2

    style style_opts

    @stack = stack left: 0, width: '100%', height: '100%' do
      @background = background white, width: '100%', height: '100%'
      @normal_border = border black
      @selected_border = border black, linestyle: :dot
      @selected_border.hide
      @words = edit_box opts[:text] || 'New Field', top: 1, left: 1, width: width - 2, height: height - 2, size: 24
    end

    @hide_border = opts[:hide_border] || false
    @normal_border.style hidden: @hide_border
    @java_text_widget = @words.gui.real

    behave!

    @font_size = @java_text_widget.get_font.get_font_data.first.get_height

    if opts[:font_size]
      @font_size = opts[:font_size]
      font_size!
    end
  end

  def select
    @normal_border.hide
    @selected_border.show
  end

  def deselect
    @normal_border.show unless @hide_border
    @selected_border.hide
  end

  private

  def behave!
    @java_text_widget.set_editable(false)
    @java_text_widget.add_listener(::Swt::SWT::MouseDown, CoolListener.new(app.gui, self))
    @java_text_widget.add_listener(::Swt::SWT::MouseUp, CoolListener.new(app.gui, self))
    @java_text_widget.add_listener(::Swt::SWT::MouseDoubleClick, CoolListener.new(app.gui, self))
    @java_text_widget.add_listener(::Swt::SWT::MouseMove, CoolListener.new(app.gui, self))
  end
end
