using GLMakie

GLMakie.set_window_config!(float=true, framerate=60)
set_theme!(resolution=(1024, 1024))

#        arguments:
@recipe(GraphPlot, vertices, connections) do scene
    Attributes(
        # Keyword arguments
        vertex_color = :red,
        connection_color = :grey
    )
end

# expands to (heavily reduced psydo code):
quote
    function graphplot end
    const GraphPlot = Combined{graphplot}
    graphplot(args...) = plot(GraphPlot, args...)
    function graphplot!(figlike, args...)
        args_converted = convert_arguments(GraphPlot, args...)
        plot = GraphPlot(args_converted...)
        plot!(plot) # that's what you overload!
        push!(figlike, plot)
    end
    function Makie.default_theme(scene, ::Type{<:GraphPlot})
        (scene -> Attributes(vertex_color = :red))(scene)
    end
end;

# implement the actual recipe
function Makie.plot!(plot::GraphPlot)
    vertices = plot.vertices

    segments = lift(plot.connections) do connections
        segments = Point2f[]
        for ij in connections
            i, j = Tuple(ij) # For CartesianIndex
            push!(segments, vertices[][i], vertices[][j])
        end
        return segments
    end

    linesegments!(plot, segments, color=plot.connection_color)
    scatter_plot = scatter!(plot, vertices, color=plot.vertex_color, markersize=10)

    old_position = Ref{Point2f}()
    scene = Makie.parent_scene(plot)
    mouseevents = addmouseevents!(scene)
    drag_index = Ref(0)
    on(mouseevents.obs, priority=typemax(Int)) do event
        if event.type == MouseEventTypes.leftdragstart
            plot_over, idx = pick(scene)
            if plot_over == pl.plots[2]
                drag_index[] = idx
            end
            return Consume(true)
        elseif event.type == MouseEventTypes.leftdrag && drag_index[] > 0
            vertices[][drag_index[]] = event.data
            notify(vertices)
            notify(plot.connections)
            return Consume(true)
        elseif event.type == MouseEventTypes.leftdragstop
            drag_index[] = 0
            return Consume(true)
        end
    end
    return Consume(false)
end

begin
    points = [Point2f(sin(r), cos(r)) for r in LinRange(0, 2pi - (pi/5), 10)]
    connections = [(i, mod1(i + 1, 10)) for i in 1:10]
    fig, ax, pl = graphplot(points, connections, axis=(aspect=DataAspect(),))
    display(fig)
end

using Graphs, NetworkLayout

function Makie.convert_arguments(::Type{<:GraphPlot}, graph::Graph)
    connections = findall(!iszero, adjacency_matrix(graph))
    algorithm = SFDP(Ptype=Float32, tol=0.01, C=0.2, K=1)
    vertices = algorithm(graph)
    return (vertices, connections)
end

begin
    g = wheel_graph(10)
    f, ax, pl = graphplot(g); display(f)
    # INTERACTION, YAY!
    # pl[1] = wheel_graph(20)
    # reset_limits!(ax) # or ctrl + double leftclick
    # pl.vertex_color = :blue
    display(f)
end

begin
    f, ax, pl = graphplot(g)
    deregister_interaction!(ax, :rectanglezoom)
    display(f)
end

# Experimental

struct MyGraph
    graph
end

function Makie.convert_arguments(::Type{<: Makie.Plot(MyGraph)}, x::MyGraph)
    return PlotSpec{GraphPlot}(convert_arguments(GraphPlot, x.graph)...; vertex_color=:yellow)
end

Makie.used_attributes(::Type{<: GraphPlot}, graph::Graph) = (:algorithm,)

function Makie.convert_arguments(::Type{<:GraphPlot}, graph::Graph; algorithm=SFDP(Ptype=Float32, tol=0.01, C=0.2, K=1))
    connections = findall(!iszero, adjacency_matrix(graph))
    vertices = algorithm(graph)
    return (vertices, connections)
end

plot(MyGraph(wheel_graph(10))) |> display

begin
    g = watts_strogatz(1000, 5, 0.03; seed=5)
    f, ax, pl = graphplot(g; algorithm=Spectral(dim=2))
    deregister_interaction!(ax, :rectanglezoom)
    display(f)
end
