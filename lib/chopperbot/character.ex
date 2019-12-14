defmodule Chopperbot.Character do
  @doc """
  Make the bot cuter with the actual quote of Chopper
  ref: https://koei.fandom.com/wiki/Tony_Tony_Chopper/Quotes
  """
  def happy_talk() do
    Enum.random([
      "Wowww! I'm rocking this!",
      "All right! I got 'em!",
      "This is this power I've got!",
      "I want to be the sort of man people can rely on!",
      "I gotta give my all for everyone in my crew!",
      "Hey! I did it!",
      "I will be even more dependable!",
      "I am a brash... monster!",
      "Wowowow!!! I'm so strooong!"
    ])
  end

  def confused_talk() do
    Enum.random([
      "Sorry, I am confusing.",
      "At least my nose isn't big and red.",
      "Sorry!! I'll patch you up once this is over, 'kay?!",
      "Hope no one minds if we take this."
    ])
  end
end
