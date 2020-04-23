module IsSoftDeletable
  extend ActiveSupport::Concern
  
  included do
    default_scope { where(is_not_deleted: true) }
    validates :is_not_deleted, inclusion: { in: [true, false] }
  end
end
