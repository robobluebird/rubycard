class CoolCard < CoolElement
  attr_accessor :stack

  def initialize_widget(opts = {})
    @stack = stack top: 0, left: 0, height: '100%', width: '100%' do
      opts[:elements].each do |e|
        instance_eval e.represent!
      end
    end
  end
end
