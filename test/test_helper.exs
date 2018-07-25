ExUnit.configure(assert_receive_timeout: 1_000)
ExUnit.start()

defmodule TestHelper do
  def random_name do
    adjectives = ["lazy", "funny", "bright", "boring", "crazy", "lonely"]
    nouns = ["thermometer", "switch", "scale", "bulb", "heater", "microwave"]

    "#{Enum.random(adjectives)}-#{Enum.random(nouns)}-#{:rand.uniform(100_000)}"
  end
end

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
