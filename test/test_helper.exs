ExUnit.start()

defmodule TestConfig do

  def mqtt_host do
    System.get_env("MQTT_HOST") || "localhost"
  end

  def mqtt_port do
    {port, _} = ( System.get_env("MQTT_PORT") || "1883" ) |> Integer.parse
    port
  end

  def mqtt_timeout do
    500
  end
end
