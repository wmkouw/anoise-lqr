time = Observable(0.0)

xs = range(0, 7, length=40)

ys_1 = @lift(sin.(xs .- $time))
ys_2 = @lift(cos.(xs .- $time) .+ 3)

fig = lines(ys_1, ys_2, color = :blue, linewidth = 4,
    axis = (title = @lift("t = $(round($time, digits = 1))"),))

framerate = 30
timestamps = range(0, 2, step=1/framerate)

record(fig, "figures/test_anim.mp4", timestamps; framerate = framerate) do t
    time[] = t
end