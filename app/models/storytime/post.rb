module Storytime
  class Post < ActiveRecord::Base
    include Storytime::Concerns::HasVersions
    include ActionView::Helpers::SanitizeHelper

    extend FriendlyId

    HTML_TITLE_CHARACTER_LIMIT = 70
    HTML_DESCRIPTION_CHARACTER_LIMIT = 160
    EXCERPT_CHARACTER_LIMIT = Storytime.post_excerpt_character_limit

    attr_accessor :preview, :published_at_date, :published_at_time, :send_subscriber_email

    friendly_id :slug_candidates, use: [:history]

    belongs_to :featured_media, class_name: 'Media'
    belongs_to :language
    belongs_to :post_category
    belongs_to :user, class_name: Storytime.user_class

    has_one :autosave, as: :autosavable, dependent: :destroy, class_name: 'Autosave'

    has_many :comments
    has_many :taggings, dependent: :destroy
    has_many :tags, through: :taggings

    before_validation :populate_excerpt_from_content
    before_validation :populate_title_alternative_from_title

    validates :excerpt, length: {in: 0 .. EXCERPT_CHARACTER_LIMIT}
    validates :language_id, presence: true
    validates :post_category_id, presence: true
    validates :title, length: {in: 1 .. Storytime.post_title_character_limit}
    validates :type, inclusion: {in: Storytime.post_types}
    validates :user, presence: true
    validates_presence_of :title, :draft_content

    before_save :sanitize_content
    before_save :set_published_at

    scope :last_published, -> (count) {where.not(published_at: nil).order(:published_at).last(count).reverse}
    scope :primary_feed, -> {where(type: primary_feed_types)}
    scope :where_lang, -> (lang) {joins(:language).where(storytime_languages: {lang: lang})}

    class << self
      def policy_class
        Storytime::PostPolicy
      end

      def primary_feed_types
        Storytime.post_types.map do |post_type|
          post_type.constantize
        end.select do |post_type|
          post_type.included_in_primary_feed?
        end
      end

      def human_name
        @human_name ||= type_name.humanize.split(' ').map(& :capitalize).join(' ')
      end

      def find_preview(id)
        Post.friendly.find(id)
      end

      def type_name
        to_s.split('::').last.underscore
      end

      def tagged_with(name)
        if t = Storytime::Tag.find_by(name: name)
          joins(:taggings).where(storytime_taggings: {tag_id: t.id})
        else
          none
        end
      end

      def tag_counts(lang: nil)
        req = Storytime::Tag.select('storytime_tags.*, count(storytime_taggings.tag_id) as count')
        if lang.nil?
          req.joins(:taggings).group('storytime_tags.id')
        else
          language_id = Language.find_by_lang(lang)
          req.joins(:taggings, :posts).where(storytime_posts: {language_id: language_id}).group('storytime_tags.id')
        end
      end

      def included_in_primary_feed?
        true
      end

      def model_name
        ActiveModel::Name.new(self, nil, 'Post')
      end
    end

    def human_name
      self.class.human_name
    end

    def type_name
      self.class.type_name
    end

    def tag_list
      tags.map(& :name).join(', ')
    end

    def tag_list=(names_or_ids)
      self.tags = names_or_ids.map do |n|
        if n.empty? || n == 'nv__'
          ''
        elsif n.include?('nv__') || n.to_i == 0
          Storytime::Tag.where(name: n.sub('nv__', '').strip).first_or_create!
        else
          Storytime::Tag.find(n)
        end
      end.delete_if {|x| x === ''}
    end

    def populate_excerpt_from_content
      self.excerpt = (content || draft_content).slice(0 .. EXCERPT_CHARACTER_LIMIT) if excerpt.blank?
      self.excerpt = strip_tags(self.excerpt)
    end

    def populate_title_alternative_from_title
      self.title_alternative = self.title if title_alternative.blank?
    end

    def show_comments?
      true
    end

    def included_in_primary_feed?
      self.class.included_in_primary_feed
    end

    def author_name
      user.storytime_name.blank? ? user.email : user.storytime_name
    end

    def slug_candidates
      if slug.blank? then [:title] elsif slug_changed? then [:slug] end
    end

    def should_generate_new_friendly_id?
      slug_changed? || (slug.blank? && published_at_changed? && published_at_change.first.nil?)
    end

    def sanitize_content
      self.draft_content = sanitize(self.draft_content, tags: Storytime.whitelisted_post_html_tags) unless Storytime.whitelisted_post_html_tags.blank?
    end

    def set_published_at
      if self.published_at_date || self.published_at_time
        self.published_at = if self.published_at_time.nil?
          DateTime.parse "#{self.published_at_date}"
        elsif self.published_at_date.nil?
          DateTime.parse "#{Date.today} #{self.published_at_time}"
        else
          DateTime.parse "#{self.published_at_date} #{self.published_at_time}"
        end
      end
    end

    def select_younger_and_older_posts
      younger_post = self.get_younger_post
      older_post = self.get_older_post

      if younger_post.nil?
        [
          older_post,
          self.get_older_post(1)
        ]
      elsif older_post.nil?
        [
          younger_post,
          self.get_younger_post(1)
        ]
      else
        [
          younger_post,
          older_post
        ]
      end
    end

    def get_younger_post(index = 0)
      younger_posts = Post.where(type: self.type).where('published_at > ?', self.published_at)
      return nil if younger_posts.nil?

      younger_posts.order(:published_at)[index]
    end

    def get_older_post(index = 0)
      older_posts = BlogPost.where(type: self.type).where('published_at < ?', self.published_at)
      return nil if older_posts.nil?

      older_posts.order(:published_at).reverse[index]
    end

    def self.html_title_character_limit
      HTML_TITLE_CHARACTER_LIMIT
    end

    def self.html_description_character_limit
      HTML_DESCRIPTION_CHARACTER_LIMIT
    end

    def self.excerpt_character_limit
      EXCERPT_CHARACTER_LIMIT
    end
  end
end
