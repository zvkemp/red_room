defmodule RedRoom.Color do
  def hsl(h, s, l), do: {:hsl, h, s, l}

  @round_values [0, 15, 55, 95, 135, 175, 215, 255]
  def round_rgb({:rgb, r, g, b}) do

  end
end
