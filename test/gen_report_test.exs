defmodule GenReportTest do
  use ExUnit.Case

  alias GenReport
  alias GenReport.Support.ReportFixture

  @file_name "gen_report.csv"
  @filenames ["part_1.csv", "part_2.csv", "part_3.csv"]

  describe "build/1" do
    test "When passing file name return a report" do
      response = GenReport.build(@file_name)

      assert response == ReportFixture.build()
    end

    test "When no filename was given, returns an error" do
      response = GenReport.build()

      assert response == {:error, "Insira o nome de um arquivo"}
    end
  end

  describe "build_from_many/1" do
    test "when a file list is provided, builds the report" do
      response = GenReport.build_from_many(@filenames)

      assert response == ReportFixture.build()
    end

    test "when a string is provided, returns error" do
      filenames = "part_1.csv"

      response = GenReport.build_from_many(filenames)

      assert response == {:error, "Insira uma lista de nomes de arquivos"}
    end
  end
end
