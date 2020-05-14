# frozen_string_literal: true

require 'rails_helper'

describe DraftSequence do
  fab!(:user) { Fabricate(:user) }

  describe '.next' do
    it 'should produce next sequence for a key' do
      expect(DraftSequence.next!(user, 'test')).to eq 1
      expect(DraftSequence.next!(user, 'test')).to eq 2
    end

    it 'should not produce next sequence for non-human user' do
      user.id = -99999
      2.times { expect(DraftSequence.next!(user, 'test')).to eq(0) }
    end
  end

  describe '.current' do
    it 'should return 0 by default' do
      expect(DraftSequence.current(user, 'test')).to eq 0
    end

    it 'should return nil for non-human user' do
      user.id = -99999
      expect(DraftSequence.current(user, 'test')).to eq(nil)
    end

    it 'should return the right sequence' do
      expect(DraftSequence.next!(user, 'test')).to eq(1)
      expect(DraftSequence.current(user, 'test')).to eq(1)
    end
  end
end
