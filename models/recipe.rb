require_relative 'ingredient'

class Recipe
  attr_reader :id, :name, :instructions, :description

  def initialize(id, name, instructions = nil, description = nil)
    @id = id
    @name = name

    if instructions == nil
      @instructions = "This recipe doesn't have any instructions."
    else
      @instructions = instructions
    end

    if description == nil
      @description = "This recipe doesn't have a description."
    else
      @description = description
    end
  end

  def ingredients
    Ingredient.ingredients(id)
  end

  def self.db_connection
    begin
      connection = PG.connect(dbname: 'recipes')
      yield(connection)
    ensure
      connection.close
    end
  end

  def self.all
    all_recipes = []
    query = "SELECT recipes.id, recipes.name
    FROM recipes;"
    recipes = db_connection do |conn|
      conn.exec_params(query)
    end
    recipes.each do |recipe|
      all_recipes << Recipe.new(recipe['id'], recipe['name'])
    end
    all_recipes
  end

  def self.find(recipe_id)
    query = "SELECT recipes.id, recipes.name, recipes.instructions, recipes.description
    FROM recipes
    JOIN ingredients
    ON ingredients.recipe_id = recipes.id
    WHERE recipe_id = $1;"
    recipe_details = db_connection do |conn|
      conn.exec_params(query, [recipe_id])
    end
    Recipe.new(recipe_details[0]['id'], recipe_details[0]['name'], recipe_details[0]['instructions'], recipe_details[0]['description'])
  end
end
