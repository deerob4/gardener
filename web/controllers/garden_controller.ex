defmodule Gardener.GardenController do
  use Gardener.Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def generate(conn, %{"goal" => goal} = params) do
    population = params |> Map.get("population", "1000") |> String.to_integer()
    plant = Gardener.Speller.spell(goal, population_size: population)
    json(conn, plant)
  end
end
