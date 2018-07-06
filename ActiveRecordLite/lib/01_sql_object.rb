require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns
    information = DBConnection.execute2(<<-SQL)
    SELECT 
      *
    FROM
      #{self.table_name}
    LIMIT
      0
    SQL
    @columns = information.first.map! {|item| item.to_sym}
  end

  def self.finalize!
    columns = self.columns
    columns.each do |column|
      define_method(column) { self.attributes[column] }
      temp = column.to_s + "="
      temp = temp.to_sym
      define_method(temp) { |var| self.attributes[column] = var }
    end
  end

  def self.table_name=(table_name)
    @table = table_name
    table_name
    # ...
  end

  def self.table_name
    @table ||= self.to_s.tableize
    @table

  end

  def self.all
    information = DBConnection.execute2(<<-SQL)
    SELECT 
      *
    FROM
      #{self.table_name}
    SQL
    self.parse_all(information[1..-1])
  end

  def self.parse_all(results)
    items = []
    results.each do |hash|
      items << self.new(hash)
    end
    items
  end

  def self.find(id)
    information = DBConnection.execute2(<<-SQL)
    SELECT 
      *
    FROM
      #{self.table_name}
    where
      id = #{id}
    SQL
    cat = self.parse_all(information[1..-1])
    cat = cat.first
    cat
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_symbol = attr_name.to_sym
      raise Exception.new("unknown attribute '#{attr_name}'") unless self.class.columns.include?(attr_symbol)
      self.send(attr_symbol)
      self.send("#{attr_symbol}=", value)
    end
    # ...
  end

  def attributes
    @attributes ||= Hash.new
    # ...
  end

  def attribute_values
    self.class.columns.map{|item| self.send(item)}
  end

  def insert
    debugger
    information = DBConnection.execute2(<<-SQL)
    INSERT INTO
      table_name (self.class.columns.first.map{|x| x.to_s}.join(", "))
    VALUES
      (attribute_values.map{|x| x.to_s}.join(", "))
    SQL
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
