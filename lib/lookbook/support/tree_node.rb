module Lookbook
  class TreeNode
    include Enumerable
    include Comparable

    delegate_missing_to :content

    attr_accessor :path, :content
    attr_reader :children

    def initialize(path = nil, content = nil, position: 10000)
      @path = path.to_s
      @content = content
      @position = position
      @children = []
    end

    def id
      Utils.id(content_value(:id, path))
    end

    def name
      segments.last
    end

    def label
      content_value(:label, name.titleize)
    end

    def position
      content_value(:position, @position)
    end

    def type
      content_value(:type, :directory)
    end

    def depth
      path.split("/").size
    end

    def add_child(name, content = nil, position: 10000)
      children << TreeNode.new("#{path}/#{name}", content, position: position)
    end

    def has_child?(name)
      !!get_child(name)
    end

    def get_child(name)
      children.find { |child| child.name == name }
    end

    def content?
      content.present?
    end

    def each(&block)
      if block
        children.sort.each do |child|
          yield child
        end
      else
        to_enum(:each)
      end
    end

    def <=>(other)
      if content?
        content <=> (other.content? ? other.content : other)
      else
        [position, label] <=> [other.position, other.label]
      end
    end

    protected

    def content_value(method_name, fallback = nil)
      value = content.send(method_name) if content
      value || fallback
    end

    def segments
      path.split("/")
    end
  end
end
