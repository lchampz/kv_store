defmodule KvStore.Supervisor do
  use Supervisor



  @spec init(:ok) ::
          {:ok,
           {%{
              auto_shutdown: :all_significant | :any_significant | :never,
              intensity: non_neg_integer(),
              period: pos_integer(),
              strategy: :one_for_all | :one_for_one | :rest_for_one
            }, [{any(), any(), any(), any(), any(), any()} | map()]}}
  def init(:ok) do
    children = [
      {KvStore.Node, %{}},
      {KvStore.Replicator, %{}}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

end
