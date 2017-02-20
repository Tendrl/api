require 'spec_helper'

RSpec.describe Tendrl::Validator::UserValidator do

  UserValidator = Tendrl::Validator::UserValidator 

  before do
    Tendrl.etcd = Etcd::Client.new
    stub_users
  end

  context 'create' do

    it 'with invalid attributes' do
      validator = UserValidator.new(:create, {})
      expect(validator.valid?).to eq(false)
      expect(validator.errors[:username].size).to eq(1)
      expect(validator.errors[:email].size).to eq(1)
      expect(validator.errors[:name].size).to eq(1)
      expect(validator.errors[:password].size).to eq(1)
      expect(validator.errors[:password_confirmation].size).to eq(1)
      expect(validator.errors[:role].size).to eq(1)
    end

    it 'with valid attributes' do
      validator = UserValidator.new(:create, {
        name: 'Tom Hardy',
        email: 'tom@tendrl.org',
        username: 'thardy',
        password: 'temp1234',
        password_confirmation: 'temp1234',
        role: Tendrl::User::ADMIN
      })
      expect(validator.valid?).to eq(true)
    end

    it 'with existing username/email' do
      validator = UserValidator.new(:create, {
        name: 'David Warner',
        email: 'dwarner@tendrl.org',
        username: 'dwarner',
        password: 'temp1234',
        password_confirmation: 'temp1234',
        role: Tendrl::User::ADMIN
      })
      expect(validator.valid?).to eq(false)
      expect(validator.errors[:username].size).to eq(1)
      expect(validator.errors[:email].size).to eq(1)
    end

  end

  context 'update' do

    it 'with valid attributes and no password' do
      validator = UserValidator.new(:update, {
        name: 'Tom Hardy',
        email: 'tom@tendrl.org',
        username: 'thardy',
        role: Tendrl::User::NORMAL
      })
      expect(validator.valid?).to eq(true)
    end

    it 'with valid attributes and invalid password' do
      validator = UserValidator.new(:update, {
        name: 'Tom Hardy',
        email: 'tom@tendrl.org',
        username: 'thardy',
        password: 'temp',
        password_confirmation: 'temp',
        role: Tendrl::User::NORMAL
      })
      expect(validator.valid?).to eq(false)
      expect(validator.errors[:password].size).to eq(1)
    end

    it 'with valid attributes and password' do
      validator = UserValidator.new(:update, {
        name: 'Tom Hardy',
        email: 'tom@tendrl.org',
        username: 'thardy',
        password: 'temp1234',
        password_confirmation: 'temp1234',
        role: Tendrl::User::NORMAL
      })
      expect(validator.valid?).to eq(true)
    end

    it 'with existing username/email' do
      validator = UserValidator.new(:update, {
        name: 'David Warner',
        email: 'dwarner@tendrl.org',
        username: 'dwarner',
        password: 'temp1234',
        password_confirmation: 'temp1234'
      })
      expect(validator.valid?).to eq(false)
      expect(validator.errors[:username].size).to eq(1)
      expect(validator.errors[:email].size).to eq(1)
    end


  end

end
