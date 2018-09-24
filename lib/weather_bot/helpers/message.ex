defmodule Helpers.Message do
  @moduledoc false

  def showWeather(
        %{
          "fact" => %{
            "condition" => condition,
            "temp" => temp,
            "wind_dir" => wind_dir,
            "wind_speed" => wind_speed
          }
        },
        chId
      ) do


    Nadia.send_message(
      chId,
      "За окном *#{getCondition(condition)}*, температура *#{temp} °C*, направление ветра *#{
        getWind(wind_dir)
      }* со скоростью *#{
        wind_speed
      }* м/с",
      parse_mode: :Markdown
    )
  end

  def sendHellow(name, chId) do
    Nadia.send_message(
      chId,
      "Привет, #{name}! Пришли мне адрес, а я скажу погоду там.",
      reply_markup: %{
        keyboard: [[
          %{
            text: "Отправить местоположение",
            request_location: true
          }
        ]]
      }
    )
  end

  def sendError(chId) do
    Nadia.send_message(chId, "К сожалению, произшла ошибка. Попробуйте позже.")
  end

  def sendNotFound(chId) do
    Nadia.send_message(chId, "К сожалению, по вашему запросу ничего не найдено. Попробуйте ещё.")
  end

  def sendResult(weather, chId, city) do
    Nadia.send_message(chId, "Погода в городе #{city}:")
    Nadia.send_message(chId, "```\n#{escapeMarkdown(weather)}```", parse_mode: :Markdown)
  end

  def sendReauth(chId) do
    Nadia.send_message(chId, "Что-то пошло не так... Нажмите /start")
  end

  def escapeMarkdown(text) do
    Regex.replace(~r/`$/iu, text, "``")
  end

  defp getCondition("clear"), do: "ясно"
  defp getCondition("partly-cloudy"), do: "малооблачно"
  defp getCondition("cloudy"), do: "облачно с прояснениями"
  defp getCondition("overcast"), do: "пасмурно"
  defp getCondition("partly-cloudy-and-light-rain"), do: "небольшой дождь"
  defp getCondition("partly-cloudy-and-rain"), do: "дождь"
  defp getCondition("overcast-and-rain"), do: "сильный дождь"
  defp getCondition("overcast-thunderstorms-with-rain"), do: "сильный дождь, гроза"
  defp getCondition("cloudy-and-light-rain"), do: "небольшой дождь"
  defp getCondition("overcast-and-light-rain"), do: "небольшой дождь"
  defp getCondition("cloudy-and-rain"), do: "дождь"
  defp getCondition("overcast-and-wet-snow "), do: "дождь со снегом"
  defp getCondition("partly-cloudy-and-light-snow"), do: "небольшой снег"
  defp getCondition("partly-cloudy-and-snow"), do: "снег"
  defp getCondition("overcast-and-snow"), do: "снегопад"
  defp getCondition("cloudy-and-light-snow"), do: "небольшой снег"
  defp getCondition("overcast-and-light-snow"), do: "небольшой снег"
  defp getCondition("cloudy-and-snow"), do: "снег"

  defp getWind("nw"), do: "северо-западное"
  defp getWind("n"), do: "северное"
  defp getWind("ne"), do: "северо-восточное"
  defp getWind("e"), do: "восточное"
  defp getWind("se"), do: "юго-восточное"
  defp getWind("s"), do: "южное"
  defp getWind("sw"), do: "юго-западное"
  defp getWind("w"), do: "западное"
  defp getWind("c"), do: "штиль"

end
