defmodule GenReport do
  alias GenReport.Parser

  @initial_report %{
    "all_hours" => %{},
    "hours_per_month" => %{},
    "hours_per_year" => %{}
  }

  def build do
    {:error, "Insira o nome de um arquivo"}
  end

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.to_list()
    |> Enum.reduce(@initial_report, &sum_values/2)
  end

  def build_from_many(params) when not is_list(params),
    do: {:error, "Insira uma lista de nomes de arquivos"}

  def build_from_many(filenames) do
    filenames
    |> Task.async_stream(&build/1)
    |> Enum.reduce(@initial_report, fn {:ok, result}, report -> sum_reports(report, result) end)
  end

  defp sum_values([name, hours, _day, month, year], acc) do
    acc
    |> add_name(name)
    |> add_month(name, month)
    |> add_year(name, year)
    |> update_in(["all_hours", name], fn value -> sum_hours(value, hours) end)
    |> update_in(["hours_per_month", name, month], fn value -> sum_hours(value, hours) end)
    |> update_in(["hours_per_year", name, year], fn value -> sum_hours(value, hours) end)
  end

  defp add_name(report, name) do
    with nil <- get_in(report, ["all_hours", name]) do
      report
      |> update_in(["all_hours"], fn names -> Map.put(names, name, 0) end)
      |> update_in(["hours_per_month"], fn names -> Map.put(names, name, %{}) end)
      |> update_in(["hours_per_year"], fn names -> Map.put(names, name, %{}) end)
    else
      _ -> report
    end
  end

  defp add_month(report, name, month) do
    with nil <- get_in(report, ["hours_per_month", name, month]) do
      update_in(report, ["hours_per_month", name], fn months -> Map.put(months, month, 0) end)
    else
      _ -> report
    end
  end

  defp add_year(report, name, year) do
    with nil <- get_in(report, ["hours_per_year", name, year]) do
      update_in(report, ["hours_per_year", name], fn years -> Map.put(years, year, 0) end)
    else
      _ -> report
    end
  end

  defp sum_hours(nil, value), do: value
  defp sum_hours(value_1, value_2), do: value_1 + value_2

  defp sum_reports(
         %{
           "all_hours" => all_hours_1,
           "hours_per_month" => hours_per_month_1,
           "hours_per_year" => hours_per_year_1
         },
         %{
           "all_hours" => all_hours_2,
           "hours_per_month" => hours_per_month_2,
           "hours_per_year" => hours_per_year_2
         }
       ) do
    %{
      "all_hours" => merge_all_hours(all_hours_1, all_hours_2),
      "hours_per_month" => merge_hours_per_month(hours_per_month_1, hours_per_month_2),
      "hours_per_year" => merge_hours_per_year(hours_per_year_1, hours_per_year_2)
    }
  end

  defp merge_all_hours(all_hours_1, all_hours_2) do
    merge_maps(all_hours_1, all_hours_2)
  end

  defp merge_hours_per_month(hours_per_month_1, hours_per_month_2) do
    Map.merge(hours_per_month_1, hours_per_month_2, fn _key, value1, value2 ->
      merge_maps(value1, value2)
    end)
  end

  defp merge_hours_per_year(hours_per_year_1, hours_per_year_2) do
    Map.merge(hours_per_year_1, hours_per_year_2, fn _key, value1, value2 ->
      merge_maps(value1, value2)
    end)
  end

  defp merge_maps(value1, value2) do
    Map.merge(value1, value2, fn _key, v1, v2 -> v1 + v2 end)
  end
end
