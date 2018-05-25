# frozen_string_literal: true

RSpec.describe IsoBibItem do
  it 'has a version number' do
    expect(IsoBibItem::VERSION).not_to be nil
  end
end
