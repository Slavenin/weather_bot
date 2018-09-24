defmodule Model.TlgmMessage do
  @moduledoc false
  defstruct [
    call_id: nil,
    is_cmd: false,
    module: nil,
    action: nil,
    data: nil,
    msg: nil
  ]
end
