class CoolButton < CoolElement
  attr_accessor :name, :script
  attr_reader :button_style, :font_size

  def title
    @words.text
  end

  def set_title(title)
    @words.text = title
  end

  def increase_font_size
    @font_size += 2
    font_size!
  end

  def decrease_font_size
    @font_size -= 2
    font_size!
  end

  def set_font_size(font_size)
    @font_size = font_size
    font_size!
  end

  def font_size!
    @words.style size: @font_size
  end

  def style(styles = nil)
    super styles

    if @button_style == :shadow
      @shadow.style(width: width - 2, height: height - 2) if @shadow
      @background.style(width: width - 2, height: height - 2) if @background
      @normal_border.style(width: width - 2, height: height - 2) if @normal_border
    end

    @words.style(top: @words.parent.height / 2 - @words.height / 2) if @words

    @style
  end

  def initialize_widget(opts = {})
    style_opts = { width: (opts[:width] || 100), height: (opts[:height] || 25) }
    style_opts[:left] = opts[:left] || parent.width / 2 - style_opts[:width] / 2
    style_opts[:top] = opts[:top] || parent.height / 2 - style_opts[:height] / 2

    style style_opts

    @stack = stack width: '100%', height: '100%' do
      @shadow = rect 2, 2, width - 2, height - 2, 4
      @background = background white, curve: 4, width: width - 2, height: height - 2
      @normal_border = border black, curve: 4, strokewidth: 1, width: width - 2, height: height - 2
      @button_selected_border = border black, linestyle: :dot
      @button_selected_border.hide
      @words = para opts[:title] || 'New Button', left: 0, align: 'center'
      @words.style(top: @words.parent.height / 2 - @words.height / 2)
      @words.style(size: opts[:font_size]) if opts[:font_size]
    end

    set_button_style (opts[:button_style] || :shadow).to_sym

    @font_size = @words.style[:size]
    @script = opts[:script] || "puts 'hi!'"
    @name = opts[:name]
  end

  def set_button_style(type)
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

    @button_style = type
  end

  def select
    @normal_border.hide
    @shadow.hide
    @button_selected_border.show
  end

  def deselect
    @normal_border.show if @button_style != :transparent
    @shadow.show if @button_style == :shadow
    @button_selected_border.hide
  end

  def opts
    {
      'type' => 'button',
      'top' => top,
      'left' => left,
      'width' => width,
      'height' => height,
      'name' => name,
      'title' => title,
      'font_size' => @font_size,
      'button_style' => @button_style,
      'script' => @script
    }
  end
end
