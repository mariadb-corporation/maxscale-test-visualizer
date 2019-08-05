class User < ApplicationRecord
  def has_access?
    Settings.authorization.users.include? nickname
  end

  authenticates_with_sorcery! do |config|
    config.authentications_class = Authentication
  end

  has_many :authentications, :dependent => :destroy
  accepts_nested_attributes_for :authentications

  def has_linked_github?
    authentications.where(provider: 'github').present?
  end
end
