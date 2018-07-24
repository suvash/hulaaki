ExUnit.start()

defmodule TestConfig do

  def ssl_options do
    case :erlang.system_info(:otp_release) do
      '21' -> [
        ciphers: [
          %{cipher: :"3des_ede_cbc", key_exchange: :rsa, mac: :sha, prf: :default_prf}
        ]
      ]
      _ -> []
    end
  end
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
    {port, _} = (System.get_env("MQTT_WEBSOCKET_PORT") || "1884") |> Integer.parse()
    port
  end

  def mqtt_timeout do
    2000
  end
end
