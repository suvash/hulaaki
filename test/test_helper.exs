ExUnit.start()

defmodule TestConfig do
  def mqtt_host do
    System.get_env("MQTT_HOST") || "localhost"
  end

  def mqtt_port do
    {port, _} = (System.get_env("MQTT_PORT") || "1883") |> Integer.parse()
    port
  end

  def mqtt_tls_port do
    {port, _} = (System.get_env("MQTT_TLS_PORT") || "8883") |> Integer.parse()
    port
  end

  def mqtt_ws_port do
    {port, _} = (System.get_env("MQTT_WS_PORT") || "1884") |> Integer.parse()
    port
  end

  def mqtt_ws_tls_port do
    {port, _} = (System.get_env("MQTT_WS_TLS_PORT") || "8884") |> Integer.parse()
    port
  end

  def mqtt_timeout do
    2000
  end
end
