using HTTP
using JSON3
using GLMakie
using FileIO
using Chain
using GLMakie.Colors

img = Observable(@chain begin
    HTTP.get("https://apod.nasa.gov/apod/image/2107/ThorsHelmet_Miller_960.jpg")
    _.body
    IOBuffer
    load
end)
open(JSON3.read, "images.json")

f = Figure()
Axis(f[1, 1])
image!(@lift($img'))
button = Button(f[1, 2], tellheight=false)
hist(f[1, 3], @lift(vec(red.(@view($img'[1:10, 1:10])))))
notify(button.clicks)
display(f)
