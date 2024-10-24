require 'rails_helper'

describe 'Usuário acessa sua conta' do
  it 'com sucesso' do
    User.create!(name: 'Pedro', surname: 'Dias', social_number: '145.382.206-20', 
                 email: 'pedro@gmail.com', password: 'passwordpass')

    visit root_path
    click_on 'Entrar'
    within 'form' do  
      fill_in 'E-mail', with: 'pedro@gmail.com'
      fill_in 'Senha', with: 'passwordpass'
      click_on 'Entrar'
    end

    expect(page).to have_content 'Login efetuado com sucesso.'
  end

  it 'e faz logout' do
    User.create!(name: 'Pedro', surname: 'Dias', social_number: '145.382.206-20', 
                 email: 'pedro@gmail.com', password: 'passwordpass')


    visit root_path
    click_on 'Entrar'
    within 'form' do  
      fill_in 'E-mail', with: 'pedro@gmail.com'
      fill_in 'Senha', with: 'passwordpass'
      click_on 'Entrar'
    end
    click_on 'Sair'

    expect(page).to have_content 'Logout efetuado com sucesso.'
    expect(page).to have_link 'Entrar'
    expect(page).not_to have_button 'Sair'
    expect(page).not_to have_content 'Pedro - pedro@gmail.com'
  end

  it 'e é redirecionado para o cadastro do restaurante' do
  end

  it 'e é redirecionado para a tela do seu restaurante' do
  end
end