class CoolCard < CoolElement
  attr_accessor :slot

  def initialize_widget(opts = {})
    @slot = flow top: 0, left: 0, height: '100%', width: '100%' do
      background white

      opts[:elements].each do |elem|
        self.send(elem.method_sym, elem.opts)
      end
    end
  end
end
