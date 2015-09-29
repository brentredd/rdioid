require 'spec_helper'

describe Rdioid do
  describe '.config' do
    context 'when config has not been set' do
      before { Rdioid.config = nil }

      specify { expect(Rdioid.config).to be nil }
    end

    context 'when config has been set' do
      before { set_config_values }

      specify { expect(Rdioid.config).to_not be nil }
    end
  end

  describe '.configure' do
    context 'when config has not been set' do
      let(:rdioid_config) { Rdioid::Config.new }

      before { Rdioid.config = nil }

      it 'yields to a new config block' do
        expect(Rdioid::Config).to receive(:new).and_return(rdioid_config)
        expect { |c| Rdioid.configure(&c) }.to yield_with_args(rdioid_config)
      end
    end

    context 'when config has been set' do
      before { set_config_values }

      it 'yields to an existing config block' do
        expect { |c| Rdioid.configure(&c) }.to yield_with_args(Rdioid.config)
      end
    end
  end

  it 'has a version number' do
    expect(Rdioid::VERSION).not_to be nil
  end
end
