# require.pry
class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        breed TEXT NOT NULL
    )
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
    sql = <<-SQL
  INSERT INTO dogs(name, breed)
  VALUES (?,?)
  SQL
    DB[:conn].execute(sql, self.name, self.breed)
    sql1 = <<-SQL
    SELECT *FROM dogs
    SQL

    self.id = DB[:conn].execute(sql1)[0][0]
    self
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.all
    sql = <<-SQL
    SELECT * FROM dogs
    SQL
    DB[:conn].execute(sql).map { |row|
      self.new_from_db(row)
    }
  end

  def self.find_by_name(dog)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name =?
    SQL
    DB[:conn].execute(sql, dog).map { |row|
      self.new_from_db(row)
    }.first
  end

  def self.find(id)
    sql = <<-SQL
     SELECT * FROM dogs
      WHERE id = ?
      SQL

    DB[:conn].execute(sql, id).map { |row|
      self.new_from_db(row)
    }.first
  end
end
