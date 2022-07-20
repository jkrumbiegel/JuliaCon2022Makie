using HTTP
using Dates
using Chain

end_date = today()
start_date = end_date - Day(365)

@chain begin
    "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY&start_date=$start_date&end_date=$end_date"
    HTTP.get
    _.body
    open("images.json", "w") do io
        write(io, _)
    end
end
