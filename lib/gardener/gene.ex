defmodule Gardener.Gene do
  @moduledoc """
  Struct and related functions for representing a
  gene - in this case, a combination of items. 
  """

  alias Gardener.Gene

  defstruct [:id, :sequence, :fitness, :pattern]

  def construct(sequence, goal) do
    %Gene{
      id: System.unique_integer([:positive]),
      sequence: sequence,
      fitness: fitness(sequence, goal),
      pattern: pattern(sequence, goal)
    }
  end

  @doc """
  Returns the fitness of `sequence` with
  regards to a `goal`. The more letters in
  the sequence that match the goal, the
  higher the fitness.

  ## Examples

      iex> Gene.fitness("h!3lO", "hello")
      2

      iex> Gene.fitness("ang8p", "hello")
      0

      iex> Gene.fitness("hello", "hello")
      5
  """
  @spec fitness(list, list) :: integer
  def fitness(sequence, goal) do
    do_fitness(sequence, goal, 0)
  end

  defp do_fitness([], [], fitness), do: fitness
  defp do_fitness([goal|s_rest], [goal|g_rest], count) do
    do_fitness(s_rest, g_rest, count+1)
  end
  defp do_fitness([_sequence|s_rest], [_goal|g_rest], count) do
    do_fitness(s_rest, g_rest, count)
  end

  @doc """
  Returns a list.

  ## Examples

      iex> Gene.pattern("h!3lO", "hello")
      [1, 0, 0, 1, 0]

      iex> Gene.fitness("ang8p", "hello")
      [0, 0, 0, 0, 0]

      iex> Gene.fitness("hello", "hello")
      [1, 1, 1, 1, 1]
  """
  @spec fitness(list, list) :: list
  def pattern(sequence, goal) do
    do_pattern(sequence, goal, [])
  end

  defp do_pattern([], [], pattern), do: pattern
  defp do_pattern([goal|s_rest], [goal|g_rest], pattern) do
    do_pattern(s_rest, g_rest, pattern ++ [1])
  end
  defp do_pattern([_sequence|s_rest], [_goal|g_rest], pattern) do
    do_pattern(s_rest, g_rest, pattern ++ [0])
  end

  @doc """
  Combines two genes in a way that takes
  them closer to the goal.
  """
  def evolve([%Gene{sequence: a}, %Gene{sequence: b}], goal) do
    goal
    |> Enum.zip(0..length(goal))
    |> Enum.map(fn({x, index}) ->
      a = Enum.at(a, index)
      b = Enum.at(b, index)
      match = a == x or b == x
      if match, do: x, else: a
    end)
    |> construct(goal)
  end
  def evolve(_abnormal_genes, _goal) do
    {:error, :population_too_small}
  end

  def sort([%Gene{pattern: pattern} = fittest | population]) do
    # The indexes of the letters that haven't
    # evolved yet. [0, 1, 1, 1, 1, 1, 1, 1, 0]
    # would return [0, 8]
    needed_indexes =
      pattern
      |> Enum.with_index()
      |> Enum.reduce([], fn
        ({0, index}, acc) ->
          acc ++ [index]
        ({1, _index}, acc) ->
          acc
      end)

      partner = hd Enum.map(needed_indexes, &find_with_index(&1, population))

      [fittest, partner | population]
  end

  defp find_with_index(index, population) do
    Enum.find(population, fn(%Gene{pattern: pattern}) ->
      Enum.at(pattern, index) == 1
    end)
  end
end