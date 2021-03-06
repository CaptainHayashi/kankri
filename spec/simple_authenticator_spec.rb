require 'spec_helper'
require 'kankri'

describe Kankri::SimpleAuthenticator do
  let(:config) do
    {
      test: {
        password: 'hunter2',
        privileges: {
          channel_set: ['get'],
          channel: 'all'
        }
      }
    }
  end
  let(:no_password) do
    {
      test: {
        privileges: {
          channel_set: ['get'],
          channel: 'all'
        }
      }
    }
  end
  let(:no_privs) do
    {
      test: {
        password: 'hunter2'
      }
    }
  end

  subject { Kankri::SimpleAuthenticator.new(config) }

  describe '#initialize' do
    context 'when the config is valid' do
      it 'succeeds' do
        Kankri::SimpleAuthenticator.new(config)
      end
    end
    context 'when a user is missing a password' do
      specify do
        expect { Kankri::SimpleAuthenticator.new(no_password) }.to raise_error
      end
    end
    context 'when a user is missing a privilege hash' do
      specify do
        expect { Kankri::SimpleAuthenticator.new(no_privs) }.to raise_error
      end
    end
    context 'when the input is not a hash' do
      specify do
        expect { Kankri::SimpleAuthenticator.new('nope') }.to raise_error
      end
    end
  end

  describe '#authenticate' do
    context 'when the user and password are valid strings' do
      it 'returns a privilege set matching the config' do
        privs = subject.authenticate('test', 'hunter2')
        expect(privs.has?(:get, :channel_set)).to be_true
        expect(privs.has?(:put, :channel_set)).to be_false
        expect(privs.has?(:get, :channel)).to be_true
        expect(privs.has?(:put, :channel)).to be_true
        expect(privs.has?(:get, :player)).to be_false
        expect(privs.has?(:put, :player)).to be_false
      end
    end
    context 'when the user and password are valid symbols' do
      it 'returns a privilege set matching the config' do
        privs = subject.authenticate(:test, :hunter2)
        expect(privs.has?(:get, :channel_set)).to be_true
        expect(privs.has?(:put, :channel_set)).to be_false
        expect(privs.has?(:get, :channel)).to be_true
        expect(privs.has?(:put, :channel)).to be_true
        expect(privs.has?(:get, :player)).to be_false
        expect(privs.has?(:put, :player)).to be_false
      end
    end
    context 'when the user is not authorised' do
      specify do
        expect { subject.authenticate('wrong', 'hunter2') }.to raise_error(
          Kankri::AuthenticationFailure
        )
      end
    end
    context 'when the password is incorrect' do
      specify do
        expect { subject.authenticate('test', 'wrong') }.to raise_error(
          Kankri::AuthenticationFailure
        )
      end
    end
    context 'when the password is blank' do
      specify do
        expect { subject.authenticate('test', '') }.to raise_error(
          Kankri::AuthenticationFailure
        )
      end
    end
    context 'when the username is blank' do
      specify do
        expect { subject.authenticate('', 'hunter2') }.to raise_error(
          Kankri::AuthenticationFailure
        )
      end
    end
  end
end
