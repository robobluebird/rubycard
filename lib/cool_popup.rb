class CoolPopup < CoolElement
  attr_accessor :element

  def initialize_widget(element)
    @element = element
    type = element.is_a?(CoolButton) ? 'Button' : 'Field'

    window title: "#{type} Info", width: 400, height: 300 do
      stack do
        flow do
          stack width: '25%' do
            para "#{type} Name", align: 'center'
          end

          @name = edit_line width: '75%' do
            # change block
          end
        end

        flow do
          stack width: '50%' do
            para "Card #{type} number: 2"
            para "Card part number: 4"
            para "Card #{type} id: 7"
          end

          stack width: '50%' do
            flow do
              para 'Style', width: '20%'
              list_box items: ['Transparent', 'Opaque', 'Shadow', 'Rectangle'], width: '80%'
            end

            stack do
              flow do
                check do |c|
                  puts 'yay' if c.checked?
                end

                para 'Editable'
              end
            end
          end
        end

        stack do
          flow do
            stack(width: '25%') do
              button 'Text Style...', width: '90%' do
              end
            end

            stack(width: '25%') { button('Icon...', width: '90%') if false }
            stack(width: '25%') { button('LinkTo...', width: '90%') if false }

            stack(width: '25%') do
              button 'OK', width: '90%' do
                # commit changes
              end
            end
          end

          flow do
            stack(width: '25%') do
              button 'Script...', width: '90%' do
              end
            end

            stack(width: '25%') { button('Contents...', width: '90%') if false }
            stack(width: '25%') { button('Tasks...', width: '90%') if false }

            stack(width: '25%') do
              button 'Cancel', width: '90%' do
                close
              end
            end
          end
        end
      end
    end
  end
end
