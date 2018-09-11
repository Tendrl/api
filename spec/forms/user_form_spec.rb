require 'spec_helper'

RSpec.describe Tendrl::UserForm do

  UserForm = Tendrl::UserForm

  before do
    stub_users
  end

  context 'create' do

    let(:user){ Tendrl::User.new }

    it 'with invalid attributes' do
      validator = UserForm.new(user, {})
      expect(validator.valid?).to eq(false)
      expect(validator.errors[:username].size).to eq(2)
      expect(validator.errors[:email].size).to eq(1)
      expect(validator.errors[:name].size).to eq(2)
      expect(validator.errors[:password].size).to eq(1)
      expect(validator.errors[:role].size).to eq(1)
      expect(validator.errors[:email_notifications].size).to eq(1)
    end

    it 'with valid attributes' do
      validator = UserForm.new(user, {
        name: 'Tom Hardy',
        email: 'tom@example.org',
        username: 'thardy',
        password: 'temp12345',
        role: Tendrl::User::ADMIN,
        email_notifications: true
      })
      expect(validator.valid?).to eq(true)
    end

    it 'with existing username/email' do
      validator = UserForm.new(user, {
        name: 'David Warner',
        email: 'dwarner@example.org',
        username: 'dwarner',
        password: 'temp12345',
        email_notifications: true,
        role: Tendrl::User::ADMIN
      })
      expect(validator.valid?).to eq(false)
      expect(validator.errors[:username].size).to eq(1)
      expect(validator.errors[:email].size).to eq(1)
    end

  end

  context 'update' do

    let(:user){
      stub_user('dwarner')
      Tendrl::User.find('dwarner')
    }

    it 'with valid attributes and no password' do
      validator = UserForm.new(user, {
        role: Tendrl::User::NORMAL
      })
      expect(validator.valid?).to eq(true)
    end

    it 'with valid attributes and invalid password' do
      validator = UserForm.new(user, {
        password: 'temp',
        role: Tendrl::User::NORMAL
      })
      expect(validator.valid?).to eq(false)
      expect(validator.errors[:password].size).to eq(1)
    end

    it 'with valid attributes and password' do
      validator = UserForm.new(user, {
        name: 'Tom Hardy',
        email: 'tom@example.org',
        username: 'thardy',
        password: 'temp12345',
        role: Tendrl::User::NORMAL
      })
      expect(validator.valid?).to eq(true)
    end

    it 'with existing username/email' do
      validator = UserForm.new(user, {
        name: 'David Warner',
        email: 'dwarner@example.org',
        username: 'dwarner',
        password: 'temp12345',
        role: Tendrl::User::LIMITED
      })
      expect(validator.valid?).to eq(true)
    end
  end
end
