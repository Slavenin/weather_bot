defmodule Helpers.Starter do
  @moduledoc false

  def startHandler(module, id) do
    case Registry.lookup(:process_registry, id) do
      [] ->
        module.start_link(id)
      _ -> nil
    end
  end
end
