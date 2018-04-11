require 'spec_helper'

RSpec.describe GemX do
  it 'has a version number' do
    expect(GemX::VERSION).not_to be nil
  end

  describe described_class::X do
    let(:argv) do
      %w[--gem cocoapods -r >\ 1 -r <\ 1.3 -v -- pod install --no-color --help]
    end

    subject { described_class.parse!(argv) }

    it 'parses correctly' do
      expect(subject.to_h).to eq(
        arguments: %w[install --no-color --help],
        executable: 'pod',
        gem_name: 'cocoapods',
        requirements: Gem::Requirement.create(['> 1', '< 1.3']),
        verbose: true
      )
    end
  end
end
