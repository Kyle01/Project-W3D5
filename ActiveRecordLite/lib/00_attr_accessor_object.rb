class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      heredoc = <<-string 
      
      def #{name}
        @#{name}
      end
      
      def #{name}=(val)
        @#{name}=val
      end
      
      string
      class_eval(heredoc)
    end
  end
end
