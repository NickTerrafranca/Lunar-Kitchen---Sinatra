class Ingredient
  attr_reader :ingredient, :name

  def initialize(name)
    @ingredient = ingredient
    @name = name
  end

  def self.db_connection
    begin
      connection = PG.connect(dbname: 'recipes')
      yield(connection)
    ensure
      connection.close
    end
  end

  def self.ingredients(recipe_id)
    all_ingredients = []
    query = "SELECT ingredients.name
    FROM ingredients
    JOIN recipes
    ON ingredients.recipe_id = recipes.id
    WHERE recipe_id = $1;"
    ingredients = db_connection do |conn|
      conn.exec_params(query, [recipe_id])
    end
    ingredients.each do |ingredient|
      all_ingredients << Ingredient.new(ingredient['name'])
    end
    all_ingredients
  end
end
