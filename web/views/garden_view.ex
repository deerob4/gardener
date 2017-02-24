defmodule Gardener.GardenView do
  use Gardener.Web, :view

  def render("result.json", %{population: population}) do
    population
  end

  def render("goal_too_big.json", _params) do
    %{error: "Goal cannot exceed 50 characters"}
  end

  def render("population_too_big.json", _params) do
    %{error: "Population cannot exceed 10000"}
  end
end
