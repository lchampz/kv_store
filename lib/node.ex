defmodule KvStore.Node do
 use GenServer

 def init(state) do
  {:ok, state}
 end

 def start_link(state) do

   if :ets.whereis(:cache) == :undefined do
    :ets.new(:cache, [:set, :public, :named_table])
  end

  GenServer.start_link(__MODULE__, state, name: __MODULE__)
 end

 def handle_cast({:req_sync, from}, state) do
   data = :ets.tab2list(:cache)
   GenServer.cast({KvStore.Node, from}, {:rec_sync, data})
   {:noreply, state}
 end

 def handle_cast({:rec_sync, data}, _from, state) do
   :ets.insert(:cache, data)

   {:noreply, state}
 end

  def handle_cast({:replication, key, value}, _from, state) do
   :ets.insert(:cache, {key, value})

   {:noreply, state}
 end


 def handle_call({:get, key}, _from, state) do
  res = case :ets.lookup(:cache, key) do
    [{_k, v}] -> v
    [] -> :not_found
  end
  {:reply, res, state}
 end

 def handle_call({:set, key, value}, _from, state) do
  :ets.insert(:cache, {key, value})

  send(KvStore.Replicator, {:broadcast, key, value})

  {:reply, :ok, state}
 end


end
