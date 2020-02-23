defmodule Chopperbot.Worker.HealthCheckWorker do
  @moduledoc """
  This moduel is for
  1. Self health check in case the api is not available
  2. Workaround to prevent the app from being terminated by gigalixir
  """
  use GenServer
  require Logger

  @app_url Application.get_env(:chopperbot, :url)
  @module_config Application.get_env(:chopperbot, __MODULE__, [])
  @worker_enabled? @module_config[:enabled] || false
  @worker_interval_ms @module_config[:worker_interval_ms] || 600_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: {:global, __MODULE__})
  end

  def init(_) do
    if @worker_enabled? do
      Logger.info("#{__MODULE__} is enabled")
      schedule_next_health_check()
    end

    {:ok, nil}
  end

  def handle_info(:health_check, state) do
    with {:ok, %HTTPoison.Response{body: "OK"}} <- HTTPoison.get("#{@app_url}/health") do
      Logger.info("#{__MODULE__}: Health check OK")
    else
      err ->
        Logger.error("#{__MODULE__}: Health check failed. #{inspect(err)}")
        Appsignal.send_error(:failed_health_check, inspect(err), [])
    end

    schedule_next_health_check()
    {:noreply, state}
  end

  defp schedule_next_health_check do
    Process.send_after(self(), :health_check, @worker_interval_ms)
  end
end
