# frozen_string_literal: true

RSpec.describe SolidusSupport do
  describe '.payment_method_parent_class' do
    subject do
      allow(described_class.deprecator).to receive(:warn).with(
        a_string_matching(/payment_method_parent_class\b.* is deprecated/),
        any_args,
      )
      described_class.payment_method_parent_class(credit_card: credit_card)
    end

    let(:credit_card) { nil }

    before do
      allow(Spree).to receive(:solidus_gem_version) do
        Gem::Version.new(solidus_version)
      end
    end

    context 'with credit_card: false' do
      let(:solidus_version) { '2.3.1' }

      it { is_expected.to eq(Spree::PaymentMethod) }
    end

    context 'with credit_card: true' do
      let(:credit_card) { true }
      let(:solidus_version) { '2.3.1' }

      it { is_expected.to eq(Spree::PaymentMethod::CreditCard) }
    end
  end

  describe '.combined_first_and_last_name_in_address?' do
    subject { described_class.combined_first_and_last_name_in_address? }

    before do
      allow(Spree).to receive(:solidus_gem_version) do
        Gem::Version.new(solidus_version)
      end
    end

    context 'when Solidus did not have the code to combine addresses fields' do
      let(:solidus_version) { '2.9.3' }

      it { is_expected.to be_falsey }
    end

    context 'when Solidus has preference to choose if combine addresses fields' do
      let(:solidus_version) { '2.11.3' }
      before do
        allow(Spree::Config)
          .to receive(:use_combined_first_and_last_name_in_address)
          .and_return(true)
      end

      it { is_expected.to be_truthy }
    end

    context 'when Solidus only has code to combine addresses fields' do
      let(:solidus_version) { '3.0.0' }

      it { is_expected.to be_truthy }
    end
  end

  describe '.deprecator' do
    it "is an instance of ActiveSupport::Deprecation specific to SolidusSupport" do
      expect(described_class.deprecator).to be_a(ActiveSupport::Deprecation)
      expect(described_class.deprecator.gem_name).to eq("SolidusSupport")
    end
  end

  describe '.solidus_deprecator' do
    it "references the Solidus deprecator without triggering deprecations" do
      expect(described_class.solidus_deprecator).to be_a(ActiveSupport::Deprecation)
      expect(described_class.solidus_deprecator.gem_name).to eq("Solidus")
    end
  end
end
