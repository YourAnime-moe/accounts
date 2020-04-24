class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def errors_string
    errors.to_a.join(', ')
  end
end
