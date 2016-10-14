include Nanoc::Helpers::Blogging
#include Nanoc::Helpers::Tagging # Use mine to provide styles
include Nanoc::Helpers::Rendering
include Nanoc::Helpers::LinkTo
include Nanoc::Helpers::Breadcrumbs

module PostHelper
  def get_pretty_date(post)
    attribute_to_time(post[:created_at]).strftime('%B %-d, %Y')
  end

  def get_post_start(post)
    content = post.compiled_content
    if content =~ /<!--more-->/
      content = content.split('<!--more-->').first
      content = content + "<div class='read-more'><a href='#{post.path}'>Continue reading &rsaquo;</a></div>"
    end
    return content
  end

  def posts_by_date
     Hash[sorted_articles.group_by{|item| item[:year]}.map{ |y, items|
            [y, items.group_by{|i| i[:month]}]}]
   end
end

module TagsHelper
   def tags_for(item, params={})
      base_url  = params[:base_url]  || '/'
      none_text = params[:none_text] || '(none)'
      separator = params[:separator] || ', '

      if item[:tags].nil? or item[:tags].empty?
        none_text
      else
        item[:tags].map { |tag| link_for_tag(tag, base_url) }.join(separator)
      end
    end

    def items_with_tag(tag)
      @items.select { |i| (i[:tags] || []).include?(tag) }
    end

    def link_for_tag(tag, base_url)
      %[<a href="#{h base_url}#{h tag}" class="page__taxonomy-item" rel="tag">#{h tag}</a>]
    end
end

module CategoriesHelper
   def categories_for(item, params={})
      base_url  = params[:base_url]  || '/'
      none_text = params[:none_text] || '(none)'
      separator = params[:separator] || ', '

      if item[:categories].nil? or item[:categories].empty?
        none_text
      else
        item[:categories].map { |categories| link_for_categories(categories, base_url) }.join(separator)
      end
    end

    def items_with_categories(categories)
      @items.select { |i| (i[:categories] || []).include?(categories) }
    end

    def link_for_categories(categories, base_url)
      %[<a href="#{h base_url}#{h categories}" class="page__taxonomy-item" rel="categories">#{h categories}</a>]
    end
end

module PaginationHelper
   def paginate_articles(item, params={})
      articles_to_paginate = sorted_articles
      page_size = params[:page_size] || 5

      article_groups = []
      until articles_to_paginate.empty?
         article_groups << articles_to_paginate.slice!(0..page_size-1)
      end

      article_groups.each_with_index do |subarticles, i|
        first = i*config[:page_size] + 1
        last  = (i+1)*config[:page_size]

        @items << Nanoc::Item.new(
          "… page content here …",
          { :title => "Archive (articles #{first} to #{last})" },
          "/blog/archive/#{i+1}/"
        )
      end
   end
end

include PostHelper
include TagsHelper
include CategoriesHelper
include PaginationHelper
