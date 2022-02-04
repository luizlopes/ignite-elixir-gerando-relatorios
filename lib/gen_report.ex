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
end
