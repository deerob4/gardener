defmodule Gardener.GardenController do
  use Gardener.Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def generate(conn, %{"goal" => goal}) when byte_size(goal) > 50 do
    conn
    |> put_status(:bad_request)
    |> render("goal_too_big.json")
  end

  def generate(conn, %{"goal" => goal} = params) do
    population = get_population(params)

    if population > 10000 do
      conn
      |> put_status(:bad_request)
      |> render("population_too_big.json")
    else
      plant = Gardener.Speller.spell(goal, population_size: population)
      render(conn, "result.json", population: plant)
    end
  end

  defp get_population(params) do
    params
    |> Map.get("population", "1000")
    |> String.to_integer()
  end
end
