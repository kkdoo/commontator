require 'commontator/commontable_config'

module Commontator
  module ActsAsCommontable
    def self.included(base)
      base.class_attribute :is_commontable
      base.is_commontable = false
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def acts_as_commontable(options = {})
        class_eval do
          cattr_accessor :commontable_config
          self.commontable_config = Commontator::CommontableConfig.new(options)
          self.is_commontable = true

          has_one :thread, :as => :commontable, :class_name => 'Commontator::Thread'
          has_many :comments, :class_name => 'Commontator::Comment', :through => :thread

          has_many :subscriptions, :class_name => 'Commontator::Subscription', :through => :thread
          
          validates_presence_of :thread
          
          alias_method :thread_raw, :thread
          
          def thread
            raw = thread_raw
            return raw unless raw.nil?
            return Commontator::Thread.find_or_create_by(commontable_type: self.class.name, commontable_id: id) \
              unless id.nil?
            self.thread = Commontator::Thread.new
            self.thread.commontable = self
            self.thread
          end
        end
      end
      
      alias_method :acts_as_commentable, :acts_as_commontable
    end
  end
end

ActiveRecord::Base.send :include, Commontator::ActsAsCommontable
