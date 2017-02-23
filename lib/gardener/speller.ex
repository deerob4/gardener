defmodule Gardener.Speller do
  @moduledoc """
  Genertc algorithm for evolving words.
  """

  alias Gardener.Gene
  import Gardener.Endpoint, only: [broadcast!: 3]

  list_to_codepoints = fn(list) ->
    list
    |> Enum.to_list()
    |> List.to_string()
    |> String.codepoints()
  end

  lower_alphabet = list_to_codepoints.(?a..?z)
  upper_alphabet = list_to_codepoints.(?A..?Z)

  digits = 0..9
    |> Enum.to_list()
    |> Enum.map(&Integer.to_string/1)

  punctuation = [33..47, 58..64, 91..96, 123..126]
    |> Enum.concat()
    |> list_to_codepoints.()

  @possibilities Enum.concat([digits, lower_alphabet, upper_alphabet, punctuation, [" "]])

  @doc """
  Simulates natural selection in order to evolve
  `goal` from a population of random strings.
  """
  def spell(goal, opts \\ []) when byte_size(goal) <= 94 do
    population_size = Keyword.get(opts, :population_size, 1000)
    goal = String.codepoints(goal)

    # Generate an initial set of data
    initial_population = generate_population(population_size, goal)
    # Remove genes with a fitness of 0; they're useless
    strengthened_pool = Enum.filter(initial_population, &(&1.fitness > 0))
    # Get rid of duplicate genes
    deduplicated = remove_duplicates(strengthened_pool)
    # Move the fittest to the top so we can build a first base
    by_fitness = sort_by_fitness(deduplicated)
    # Recurse through, evolving each time
    generations = crossover(by_fitness, goal, 0, [])

    compress_genes(%{
      initial_population: initial_population,
      strengthened_pool: strengthened_pool,
      deduplicated: deduplicated,
      by_fitness: by_fitness,
      generations: generations,
    })
  end

  defp compress_genes(genes) do
    Map.new(genes, fn({pool, genes}) ->
      {pool, Enum.map(genes, &compress_gene/1)}
    end)
  end

  defp compress_gene(%Gene{id: id, sequence: sequence, fitness: fitness}) do
    %{id: id, fitness: fitness, sequence: Enum.join(sequence)}
  end

  defp crossover(population, goal, current_generation, generations) do
    # Order the population by fitness, take the top
    # two (the fittest), evolve them together, then
    # repeat. We should then end up with the fittest.
    population = Gene.sort(population)

    fittest =
      population
      |> Enum.take(2)
      |> Gene.evolve(goal)

    case fittest do
      %Gene{sequence: sequence} = gene ->
        if sequence == goal do
          generations ++ [gene]
        else
          population = Enum.drop(population, 2)
          crossover([fittest | population], goal, current_generation+1, generations ++ [gene])
        end
      _ ->
        generations
    end
  end

  defp generate_population(size, goal) do
    1..size
    |> Flow.from_enumerable()
    |> Flow.map(fn(_) ->
      sequence = random_sequence(goal)
      Gene.construct(sequence, goal)
    end)
    |> Enum.to_list()
  end

  defp random_sequence(goal) do
    sequence_length = length(goal)
    Enum.take_random(@possibilities, sequence_length)
  end

  defp sort_by_fitness(population) do
    Enum.sort(population, &(&1.fitness > &2.fitness))
  end

  defp remove_duplicates(population) do
    Enum.uniq_by(population, fn(%Gene{pattern: pattern}) ->
      pattern
    end)
  end
end
