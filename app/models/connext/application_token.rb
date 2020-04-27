module Connext
  class ApplicationToken < ApplicationRecord
    belongs_to :application
    scope :active, -> { where("expires_in > '#{DateTime.now.utc}'") }
  end
end
