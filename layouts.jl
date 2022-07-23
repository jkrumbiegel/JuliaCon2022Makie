using GLMakie

GLMakie.activate!()
GLMakie.set_window_config!(float=true)


## gridlayout basics

f = Figure(fontsize=30)

Box(f[1, 1:3], color=:transparent, strokecolor=:red)
Box(f[2, 1:3], color=:transparent, strokecolor=:red)
Box(f[3, 1:3], color=:transparent, strokecolor=:red)

Box(f[1:3, 1], color=:transparent, strokecolor=:blue)
Box(f[1:3, 2], color=:transparent, strokecolor=:blue)
Box(f[1:3, 3], color=:transparent, strokecolor=:blue)

##

ax1 = Axis(f[1, 1])

ax2 = Axis(f[1:2, 2])

cb = Colorbar(f[:, 3])

cb.tellwidth = false
cb.tellwidth = true

l = Label(f[end+1, 2], "Label")
l.tellwidth = false

l2 = Label(f[end+1, :], "Long long long long long label")

ax2.title = "A title"
ax2.alignmode = Outside()
ax2.alignmode = Inside()
ax2.alignmode = Mixed(bottom=0)
ax2.alignmode = Mixed(bottom=0, top=30)

colgap!(f.layout, 1, 80)

## aspects

f = Figure()
gl1 = GridLayout(f[1, 1])
gl2 = GridLayout(f[2, 1])
ax = Axis(gl1[1, 1], aspect=1)
Box(gl1[1, 2])
ax2 = Axis(gl2[1, 1])
Box(gl2[1, 2])
colsize!(gl2, 1, Aspect(1, 1.0))
# why not rowsize! ?
f
