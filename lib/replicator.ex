defmodule KvStore.Replicator do
  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  @spec init(:ok) :: {:ok, %{active_nodes: list()}}
  def init(:ok) do

    Enum.each(Node.list(), fn node ->
      GenServer.cast({KvStore.Server, node}, :sync)
    end)

    :net_kernel.monitor_nodes(true)
    {:ok, %{active_nodes: Node.list()}}
  end

  def handle_info({:broadcast, k, v}, state) do
    Enum.each(state.active_nodes, fn node ->
      GenServer.cast({KvStore.Node, node}, {:set, k, v})
    end)

    {:noreply, state}
  end

  def handle_info({:nodedown, node}, state) do
    IO.puts("node #{node} is down, removing from replication list")

    new_nodes = List.delete(state.active_nodes, node)
    {:noreply, %{state | active_nodes: new_nodes}}
  end

  def handle_info({:nodeup, node}, state) do
    IO.puts("new node (#{node})! adding on list")
    new_nodes = [ node | state.active_nodes]

    GenServer.cast({KvStore.Server, node}, {:req_sync, self()})

    {:noreply, %{state | active_nodes: new_nodes} }
  end
end
