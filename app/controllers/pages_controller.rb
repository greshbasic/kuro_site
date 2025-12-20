class PagesController < ApplicationController
  def home
    @visit = Visit.first
    @visit.increment!(:count)
  end

  def kuro_pictures
    @images = Dir.glob(Rails.root.join("app/assets/images/kuro/*.{jpg,jpeg,png,gif}")).map do |f|
      "kuro/#{File.basename(f)}"
    end

    @img_captions = {
      "kuro/adopt.jpg" => "day i adopted owner",
      "kuro/baby.jpg" => "first baf",
      "kuro/chair.jpg" => "favorite chare",
      "kuro/chillin.jpg" => "chillin.",
      "kuro/eepy.jpg" => "so eepy",
      "kuro/hiding.jpg" => "can u find me?",
      "kuro/strut.jpg" => "woooo",
      "kuro/window_nap.jpg" => "window time",
      "kuro/working.jpg" => "me making page",
      "kuro/yoga.jpg" => "what u look at",
    }
  end

  def kuro_toys
    @toys = Dir.glob(Rails.root.join("app/assets/images/toys/*.{jpg,jpeg,png,gif}")).map do |f|
      "toys/#{File.basename(f)}"
    end

    @toy_captions = {
      "toys/mouse_wand.jpg" => "i like to play this in baftub",
      "toys/octopus.jpg" => "michael",
      "toys/puzzle1.jpg" => "i like 2 take the balls out",
      "toys/puzzle2.jpg" => "spin spin",
      "toys/spring.jpg" => "why do they keep leaving me",
      "toys/table_toy.jpg" => "i want to take it off",
    }
  end
end
