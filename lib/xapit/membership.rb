module Xapit
  # Use "include Xapit::Membership" on a class to allow xapian searching on it. This is automatically included
  # in ActiveRecord::Base so you do not need to do anything there.
  module Membership
    def self.included(base)
      base.extend ClassMethods
      base.send(:attr_accessor, :xapit_relevance) # is there a better way to do this?
    end
    
    module ClassMethods
      # Used to perform a search on a model.
      #   
      #   # perform a simple full text search
      #   @articles = Article.search("phone")
      #   
      #   # add pagination if you're using will_paginate
      #   @articles = Article.search("phone", :per_page => 10, :page => params[:page])
      #   
      #   # search based on indexed fields
      #   @articles = Article.search("phone", :conditions => { :category_id => params[:category_id] })
      #   
      #   # manually sort based on any number of indexed fields, sort defaults to most relevant
      #   @articles = Article.search("phone", :order => [:category_id, :id])
      #
      def search(*args)
        Collection.new(self, *args)
      end
      
      # Simply call "xapit" on a class and pass a block to define the indexed attributes.
      # 
      #   class Article < ActiveRecord::Base
      #     xapit do |index|
      #       index.text :name, :content
      #       index.field :category_id
      #       index.facet :author_name, "Author"
      #     end
      #   end
      # 
      # First we index "name" and "content" attributes for full text searching. The "category_id" field is indexed for :conditions searching. The "author_name" is indexed as a facet with "Author" being the display name of the facet. See the facets section below for details.
      # 
      # Because the indexing happens in Ruby these attributes do no have to be database columns. They can be simple Ruby methods. For example, the "author_name" attribute mentioned above can be defined like this.
      # 
      #   def author_name
      #     author.name
      #   end
      # 
      # This way you can create a completely custom facet by simply defining your own method
      # 
      # You can also pass any find options to the xapit method to determine what gets indexed and improve performance with eager loading or a different batch size.
      # 
      #   xapit(:batch_size => 100, :include => :author, :conditions => { :visible => true })
      #
      def xapit(*args)
        @xapit_index_blueprint = IndexBlueprint.new(self, *args)
        yield(@xapit_index_blueprint)
      end
      
      # The Xapit::IndexBlueprint object used for this class.
      def xapit_index_blueprint
        @xapit_index_blueprint
      end
      
      # Finds a Xapit::FacetBlueprint for the given attribute.
      def xapit_facet_blueprint(attribute)
        result = xapit_index_blueprint.facets.detect { |f| f.attribute.to_s == attribute.to_s }
        raise "Unable to find facet blueprint for #{attribute} on #{name}" if result.nil?
        result
      end
    end
  end
end
