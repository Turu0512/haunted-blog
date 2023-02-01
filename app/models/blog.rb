# frozen_string_literal: true

class Blog < ApplicationRecord
  belongs_to :user
  has_many :likings, dependent: :destroy
  has_many :liking_users, class_name: 'User', source: :user, through: :likings

  validates :title, :content, presence: true

  scope :published, -> { where('secret = FALSE') }

  scope :search, lambda { |term|
    where('title LIKE ?', "%#{sanitize_sql(term)}%").or(where('content LIKE ?',"%#{sanitize_sql(term)}%"))
  }

  scope :default_order, -> { order(id: :desc) }

  before_save :content_escaping

  def owned_by?(target_user)
    user == target_user
  end

  def content_escaping
    self.content = html_escape(content)
  end

  def dangerous_unescaped_content
    CGI.unescapeHTML(content || '')
  end
end
