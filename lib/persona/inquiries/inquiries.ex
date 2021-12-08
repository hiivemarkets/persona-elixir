defmodule Persona.Inquiries do
  @moduledoc """
  The `Persona.Inquiries` module provides access methods to the [Inquiries API](https://docs.withpersona.com/reference/inquiries)
  All methods require a Tesla Client struct created with `Persona.client(api_key)`.

  ## Examples

      client = Persona.client("thisismykeyinpersona")
      {:ok, result, _env} = Persona.Inquiries.list_inquiries(client)
  """

  @inquiries_url "/inquiries"

  import Persona.Utils

  @doc """
  List All Inquiries

  https://docs.withpersona.com/reference/list-all-inquiries

  ##Example

      {:ok, result, _} = Persona.Inquiries.list_inquiries(client, page: %{after: "", before: ""}, filter: %{account-id: "", reference-id: ""})

  """
  @spec list_inquiries(Persona.client(), keyword()) :: Persona.result()
  def list_inquiries(client, opts \\ []) do
    Tesla.get(client, @inquiries_url, query: opts_to_query(opts)) |> Persona.result()
  end

  @doc """
  Retrieve an Inquiry

  https://docs.withpersona.com/reference/apiv1inquiriesinquiry-id

  ##Example

      {:ok, result, _} = Persona.Inquiries.retrieve_inquiry(client, "inq_thisid")

  """
  @spec retrieve_inquiry(Persona.client(), String.t()) :: Persona.result()
  def retrieve_inquiry(client, inquiry_id) do
    Tesla.get(client, @inquiries_url <> "/#{inquiry_id}")
    |> Persona.result()
  end
end
