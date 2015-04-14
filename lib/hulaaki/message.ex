defmodule Hulaaki.Message do
  @moduledoc """
  Provides the structs and constructors for different kinds of message
  packets in the MQTT protocol.
  """

  # TODO: number of topics and number of qoses must be equal

  defmodule Connect do
    @type t :: %__MODULE__{
              client_id: non_neg_integer,
              username: String.t,
              password: String.t,
              will_topic: String.t,
              will_message: String.t,
              will_qos: 0|1|2,
              will_retain: 0|1,
              clean_session: 0|1,
              keep_alive: integer,
              type: atom}
    defstruct [:client_id,
               :username,
               :password,
               :will_topic,
               :will_message,
               :will_qos,
               :will_retain,
               :clean_session,
               :keep_alive,
               type: :CONNECT]
  end

  @doc """
  Creates a Connect struct with the guards applied.
  """
  def connect(client_id, username, password,
              will_topic, will_message, will_qos,
              will_retain, clean_session, keep_alive)
    when is_binary(client_id)
    and client_id > 0
    and is_binary(username)
    and is_binary(password)
    and is_binary(will_topic)
    and is_binary(will_message)
    and (will_qos == 0 or will_qos == 1 or will_qos == 2)
    and (will_retain == 0 or will_retain == 1)
    and (clean_session == 0 or clean_session == 1)
    and is_integer(keep_alive) do

      %Connect{client_id: client_id, username: username, password: password,
               will_topic: will_topic, will_message: will_message,
               will_qos: will_qos, will_retain: will_retain,
               clean_session: clean_session, keep_alive: keep_alive}
  end

  defmodule ConnAck do
    @type t :: %__MODULE__{session_present: 0|1, return_code: 1|2|3|4|5, type: atom}
    defstruct [:session_present, :return_code, type: :CONNACK]
  end

  @doc """
  Creates a ConnAck struct with the guards applied.
  """
  def connect_ack(session_present, return_code)
    when (session_present == 0 or session_present == 1)
    and (return_code == 0 or return_code == 1 or
         return_code == 2 or return_code == 3 or
         return_code == 4 or return_code == 5) do

      %ConnAck{session_present: session_present, return_code: return_code}
  end

  defmodule Publish do
    @type t :: %__MODULE__{
               id: non_neg_integer,
               topic: String.t,
               message: String.t,
               dup: 0|1,
               qos: 0|1|2,
               retain: 0|1,
               type: atom}
    defstruct [:id, :topic, :message, :dup, :qos, :retain, type: :PUBLISH]
  end

  @doc """
  Creates a Publish struct with the guards applied.
  """
  def publish(packet_id, topic, message, dup, qos, retain)
    when is_integer(packet_id)
    and packet_id > 0
    and is_binary(topic)
    and is_binary(message)
    and (dup == 0 or dup == 1)
    and (qos == 0 or qos == 1 or qos == 2)
    and (retain == 0 or retain == 1) do

      %Publish{id: packet_id, topic: topic, message: message,
               dup: dup, qos: qos, retain: retain}
  end

  defmodule PubAck do
    @type t :: %__MODULE__{id: non_neg_integer, type: atom}
    defstruct [:id, type: :PUBACK]
  end

  @doc """
  Creates a PubAck struct with the guards applied.
  """
  def publish_ack(packet_id)
    when is_integer(packet_id)
    and packet_id > 0 do

      %PubAck{id: packet_id}
  end

  defmodule PubRec do
    @type t :: %__MODULE__{id: non_neg_integer, type: atom}
    defstruct [:id, type: :PUBREC]
  end

  @doc """
  Creates a PubRec struct with the guards applied.
  """
  def publish_receive(packet_id)
    when is_integer(packet_id)
    and packet_id > 0 do

      %PubRec{id: packet_id}
  end

  defmodule PubRel do
    @type t :: %__MODULE__{id: non_neg_integer, type: atom}
    defstruct [:id, type: :PUBREL]
  end

  @doc """
  Creates a PubRel struct with the guards applied.
  """
  def publish_release(packet_id)
    when is_integer(packet_id)
    and packet_id > 0 do

      %PubRel{id: packet_id}
  end

  defmodule PubComp do
    @type t :: %__MODULE__{id: non_neg_integer, type: atom}
    defstruct [:id, type: :PUBCOMP]
  end

  @doc """
  Creates a PubComp struct with the guards applied.
  """
  def publish_complete(packet_id)
    when is_integer(packet_id)
    and packet_id > 0 do

      %PubComp{id: packet_id}
  end
  defmodule Subscribe do
    @type t :: %__MODULE__{
               id: non_neg_integer,
               topics: list(String.t),
               requested_qoses: list(0|1|2),
               type: atom}
    defstruct [:id, :topics, :requested_qoses, type: :SUBSCRIBE]
  end

  @doc """
  Creates a Subscribe struct with the guards applied.
  """
  def subscribe(packet_id, topics, requested_qoses)
    when is_integer(packet_id)
    and packet_id > 0
    and is_list(topics)
    and is_list(requested_qoses)
    and length(requested_qoses) == length(topics) do
      clean_topics = Enum.filter(topics, fn(x) -> is_binary(x) end)
      valid_qos? = fn(x) -> (x == 0 or x == 1 or x == 2) end
      clean_qoses = Enum.filter(requested_qoses, valid_qos?)

      %Subscribe{id: packet_id, topics: clean_topics, requested_qoses: clean_qoses}
  end

  defmodule SubAck do
    @type t :: %__MODULE__{
               id: non_neg_integer,
               granted_qoses: list(0|1|2|128),
               type: atom}
    defstruct [:id, :granted_qoses, type: :SUBACK]
  end

  @doc """
  Creates a SubAck struct with the guards applied.
  """
  def subscribe_ack(packet_id, granted_qoses)
    when is_integer(packet_id)
    and packet_id > 0
    and is_list(granted_qoses) do
      valid_qos? = fn(x) -> (x == 0 or x == 1 or x == 2 or x == 128) end
      clean_qoses = Enum.filter(granted_qoses, valid_qos?)

      %SubAck{id: packet_id, granted_qoses: clean_qoses}
  end

  defmodule Unsubscribe do
    @type t :: %__MODULE__{id: non_neg_integer, topics: list(String.t), type: atom}
    defstruct [:id, :topics, type: :UNSUBSCRIBE]
  end

  @doc """
  Creates a Unsubscribe struct with the guards applied.
  """
  def unsubscribe(packet_id, topics)
    when is_integer(packet_id)
    and packet_id > 0
    and is_list(topics) do
      clean_topics = Enum.filter(topics, fn(x) -> is_binary(x) end)

      %Unsubscribe{id: packet_id, topics: clean_topics}
  end

  defmodule UnsubAck do
    @type t :: %__MODULE__{id: non_neg_integer, type: atom}
    defstruct [:id, type: :UNSUBACK]
  end

  @doc """
  Creates a UnsubAck struct with the guards applied.
  """
  def unsubscribe_ack(packet_id)
    when is_integer(packet_id)
    and packet_id > 0 do

      %UnsubAck{id: packet_id}
  end

  defmodule PingReq do
    @type t :: %__MODULE__{type: atom}
    defstruct type: :PINGREQ
  end

  @doc """
  Creates a Pingreq struct.
  """
  def ping_request do
    %PingReq{}
  end

  defmodule PingResp do
    @type t :: %__MODULE__{type: atom}
    defstruct type: :PINGRESP
  end

  @doc """
  Creates a Pingresp struct.
  """
  def ping_response do
    %PingResp{}
  end

  defmodule Disconnect do
    @type t :: %__MODULE__{type: atom}
    defstruct type: :DISCONNECT
  end

  @doc """
  Creates a Disconnect struct.
  """
  def disconnect do
    %Disconnect{}
  end
end
