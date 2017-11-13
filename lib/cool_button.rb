class CoolButton < CoolElement
  attr_accessor :code, :id

  attr_reader :font_size, :button_type

  def self.dsl(opts = {})
    "cool_button #{opts[:text]}, width: #{opts[:width]}, height: #{opts[:height]}, \
      button_type: #{opts[:button_type]}, font_size: #{opts[:font_size]}, code: #{opts[:code]}"
  end

  def text
    @words.text
  end

  def increase_font_size
    @font_size += 2
    font_size!
  end

  def decrease_font_size
    @font_size -= 2
    font_size!
  end

  def font_size!
    @words.style size: @font_size
  end

  def style(styles = nil)
    super styles

    if @button_type == :shadow
      @shadow.style(width: width - 2, height: height - 2) if @shadow
      @background.style(width: width - 2, height: height - 2) if @background
      @normal_border.style(width: width - 2, height: height - 2) if @normal_border
    end

    @words.style(top: @words.parent.height / 2 - @words.height / 2) if @words

    @style
  end

  def initialize_widget(opts = {})
    style_opts = { width: (opts[:width] || 100), height: (opts[:height] || 25) }
    style_opts[:left] = opts[:left] || @app.width / 2 - style_opts[:width] / 2
    style_opts[:top] = opts[:top] || @app.height / 2 - style_opts[:height] / 2

    style style_opts

    @stack = stack width: '100%', height: '100%' do
      @shadow = rect 2, 2, width - 2, height - 2, 4
      @background = background white, curve: 4, width: width - 2, height: height - 2
      @normal_border = border black, curve: 4, strokewidth: 1, width: width - 2, height: height - 2
      @selected_border = border black, linestyle: :dot
      @selected_border.hide
      @words = para opts[:text] || 'New Button', left: 0, align: 'center'
      @words.style(top: @words.parent.height / 2 - @words.height / 2)
      @words.style(size: opts[:font_size]) if opts[:font_size]
    end

    set_button_type (opts[:button_type] || :shadow).to_sym

    @font_size = @words.style[:size]
    @code = opts[:code] || "puts 'hi!'"
  end

  def toggle_button_type
    if @button_type == :shadow
      set_button_type(:transparent)
    elsif @button_type == :transparent
      set_button_type(:plain)
    elsif @button_type == :plain
      set_button_type(:shadow)
    end
  end

  def set_button_type(type)
    return nil unless [:shadow, :plain, :transparent].include? type.to_sym

    if type == :shadow
      @shadow.style(width: width - 2, height: height - 2)
      @background.style(width: width - 2, height: height - 2, curve: 4, fill: white)
      @normal_border.style(width: width - 2, height: height - 2, curve: 4, strokewidth: 1)
      @background.show
      @normal_border.show
      @shadow.show
    elsif type == :plain
      @background.style(width: '100%', height: '100%', curve: 0, fill: white)
      @normal_border.style(width: '100%', height: '100%', curve: 0, strokewidth: 1)
      @background.show
      @normal_border.show
      @shadow.hide
    elsif type == :transparent
      @background.hide
      @normal_border.hide
      @shadow.hide
    end

    @words.style(top: @words.parent.height / 2 - @words.height / 2)

    @button_type = type
  end

  def select
    @normal_border.hide
    @shadow.hide
    @selected_border.show
  end

  def deselect
    @normal_border.show if @button_type != :transparent
    @shadow.show if @button_type == :shadow
    @selected_border.hide
  end
end
