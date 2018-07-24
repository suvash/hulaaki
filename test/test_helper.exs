ExUnit.start()
ExUnit.configure(assert_receive_timeout: 500)

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

  def mqtt_websocket_port do
    {port, _} = (System.get_env("MQTT_WEBSOCKET_PORT") || "8085") |> Integer.parse()
    port
  end

  def mqtt_timeout do
    2000
  end
end
