module DogsHelper
    def size_i18n(key)
        { "small"=>"小型犬", "medium"=>"中型犬", "large"=>"大型犬" }[key]
    end

    def age_i18n(key)
        { "puppy"=>"子犬", "adult"=>"成犬", "senior"=>"シニア犬" }[key]
    end

    def body_i18n(key)
        { "thin"=>"痩せ型", "normal"=>"普通体型", "overweight"=>"肥満" }[key]
    end

    def activity_i18n(key)
        { "low"=>"穏やか", "medium"=>"普通", "high"=>"活発" }[key]
    end
end