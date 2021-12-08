defmodule Persona.Utils do
  @spec stringify_keys(any) :: any
  def stringify_keys(nil), do: nil

  def stringify_keys(%{__struct__: _} = struct) do
    struct
    |> Map.from_struct()
    |> stringify_keys()
  end

  def stringify_keys(map = %{}) do
    map
    |> Enum.map(fn {k, v} ->
      case k do
        k when is_atom(k) -> {Atom.to_string(k), stringify_keys(v)}
        k -> {k, stringify_keys(v)}
      end
    end)
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> Enum.into(%{})
  end

  def stringify_keys([head | rest]) do
    [stringify_keys(head) | stringify_keys(rest)]
  end

  def stringify_keys(value) do
    value
  end

  @spec to_struct(atom, map()) :: map()
  def to_struct(kind, attrs) do
    struct = struct(kind)

    Enum.reduce(Map.to_list(struct), struct, fn {k, _}, acc ->
      case Map.fetch(attrs, Atom.to_string(k)) do
        {:ok, v} -> %{acc | k => v}
        :error -> acc
      end
    end)
  end

  @spec merge_struct(map(), map()) :: map()
  def merge_struct(struct1, struct2) do
    Enum.reduce(Map.to_list(struct1), struct1, fn {k, _}, acc ->
      case Map.fetch(struct2, k) do
        {:ok, nil} ->
          acc

        {:ok, %{__struct__: _} = struct} ->
          %{acc | k => merge_struct(Map.get(struct1, k), struct)}

        {:ok, v} ->
          %{acc | k => v}

        :error ->
          acc
      end
    end)
  end

  def opts_to_query(opts) do
    opts
    |> Enum.map(&convert_parent_keyed_param/1)
    |> Enum.filter(fn v -> !is_nil(v) end)
    |> List.flatten()
    |> Enum.into(%{})
  end

  def convert_parent_keyed_param({k, v}) when is_map(v),
    do: Enum.map(v, fn {sk, sv} -> parent_keyed_param(k, sk, sv) end)

  def convert_parent_keyed_param({k, v}) when is_atom(k), do: {Atom.to_string(k), v}
  def convert_parent_keyed_param({k, v}), do: {k, v}
  def convert_parent_keyed_param(_), do: nil
  defp parent_keyed_param(parent, key, value), do: {"#{parent}[#{key}]", value}
end
