using HTTP
using Dates
using Chain

end_date = today()
start_date = end_date - Day(365)

@chain begin
    "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY&start_date=$start_date&end_date=$end_date"
    HTTP.get
    _.body
    JSON3.read
    filter(entry -> entry["media_type"] != "video", _)
    open("images.json", "w") do io
        JSON3.write(io, _)
    end
end
