require 'pry'

class Dog

  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
    Dog.all << self
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if @id
      update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, name, breed)
      sql2 = <<-SQL
      SELECT last_insert_rowid() FROM dogs
      SQL
      @id = DB[:conn].execute(sql2).flatten[0]
      # binding.pry
    end
    return self
  end

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
    dog
    # binding.pry
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?
    SQL
    dog = DB[:conn].execute(sql, id)[0]
    # binding.pry
    info = {id: dog[0],name: dog[1], breed: dog[2] }
    Dog.create(info)
  end

  def update
    sql = <<-SQL
    UPDATE dogs SET name = ?, breed = ?;
    SQL
    DB[:conn].execute(sql, name, breed)
  end

  def self.find_or_create_by(hash)
    name = hash[:name]
    breed = hash[:breed]
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? AND breed = ?;
    SQL
    song = DB[:conn].execute(sql, name, breed).flatten
    # binding.pry
    if !song.empty?
      Dog.new(id:song[0], name:song[1], breed:song[2])
    else
      # binding.pry
      Dog.create(hash)
    end
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).flatten
    Dog.new(id:row[0], name:row[1], breed:row[2])
  end



end
