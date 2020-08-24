class AdminUser < RegularUser
  def admin?
    true
  end
end
