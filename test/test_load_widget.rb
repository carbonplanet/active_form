require 'test_helper'

class TestLoadWidget < Test::Unit::TestCase
  
  def setup
    ActiveForm::Widget.load_paths << File.join(File.dirname(__FILE__), 'resources', 'widgets')
  end
  
  def test_load_paths
    assert_equal 2, ActiveForm::Widget.load_paths.length
    assert File.directory?(ActiveForm::Widget.load_paths[0])
    assert File.directory?(ActiveForm::Widget.load_paths[1])
  end
  
  def test_load_and_build
    assert_equal ActiveForm::Widget::Custom, ActiveForm::Widget::get(:custom)
    elem = ActiveForm::Widget::build(:custom)
    assert_kind_of ActiveForm::Widget::Custom, elem
  end
  
  def test_add_widget
    form = ActiveForm::compose :form do |f|
      f.text_element :name
      f.custom_widget :my_widget
    end
    assert_equal [:text, :custom_widget], form.collect(&:element_type)
  end
  
  def test_add_widget_as_element_at_top
    form = ActiveForm::compose :form do |f|
      f.text_element :name
    end
    form.insert_element_at_top(ActiveForm::Widget::build(:custom))
    assert_equal [:custom_widget, :text], form.collect(&:element_type)
  end
  
  def test_widget_to_html
    users = [ { :id => 1, :firstname => 'Fred', :lastname => 'Flintstone' }, { :id => 2, :firstname => 'Barney', :lastname => 'Rubble' } ]
    form = ActiveForm::compose :form do |f|
      f.section :users do |s|
        users.each do |user|
          s.custom_widget "user_#{user[:id]}", :values => user
        end
      end
      f.submit_element
    end
    expected = %|<form action="#form" class="active_form" id="form" method="post">
  <table>
    <tr>
      <td>
        <label for="form_users_user_1_firstname">Firstname</label>
      </td>
      <td>
        <label for="form_users_user_1_lastname">Lastname</label>
      </td>
    </tr>
    <tr>
      <td>
        <input class="elem_text" id="form_users_user_1_firstname" name="form[users][user_1][firstname]" size="30" title="First Name" type="text" value="Fred"/>
      </td>
      <td>
        <input class="elem_text" id="form_users_user_1_lastname" name="form[users][user_1][lastname]" size="30" title="Last Name" type="text" value="Flintstone"/>
      </td>
    </tr>
  </table>
  <table>
    <tr>
      <td>
        <label for="form_users_user_2_firstname">Firstname</label>
      </td>
      <td>
        <label for="form_users_user_2_lastname">Lastname</label>
      </td>
    </tr>
    <tr>
      <td>
        <input class="elem_text" id="form_users_user_2_firstname" name="form[users][user_2][firstname]" size="30" title="First Name" type="text" value="Barney"/>
      </td>
      <td>
        <input class="elem_text" id="form_users_user_2_lastname" name="form[users][user_2][lastname]" size="30" title="Last Name" type="text" value="Rubble"/>
      </td>
    </tr>
  </table>
  <input class="elem_submit" id="form_submit" name="form[submit]" type="submit" value="Submit"/>
</form>\n|
    assert_equal expected, form.to_html
  end
  
  def teardown
    ActiveForm::Widget.load_paths.delete_at(1)
  end
  
end