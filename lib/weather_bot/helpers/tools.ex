defmodule Helpers.Tools do
  @doc """
  Делает первую букву заглавной
  """
  @spec capitalize(binary()) :: binary()
  def capitalize(text) do
    String.upcase(String.first(text)) <> String.slice(text, 1..-1)
  end

  @doc """
  Проверяет реализует ли модуль нужное поведение
  """
  @spec isBehaviours?(atom() | %{module_info: nil | keyword() | map()}, any()) :: boolean()
  def isBehaviours?(module, behaviour) do
    module.module_info[:attributes]
    |> Keyword.get(:behaviour, [])
    |> Enum.member?(behaviour)
  end
end
