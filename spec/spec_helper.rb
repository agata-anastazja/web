require 'simplecov'
SimpleCov.start 'rails'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rr

  config.before(:each) { StripeMock.start }
  config.after(:each)  { StripeMock.stop }

  # config.order = :random
  # Kernel.srand config.seed
end
