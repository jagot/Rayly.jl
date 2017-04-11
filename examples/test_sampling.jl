using Rayly
using PyPlot
MultipleLocator = matplotlib[:ticker][:MultipleLocator]

function test_sampling(s)
    i,j = 10.,9.
    samples = s(i,j)
    x,y = zip(samples...)
    plot(x,y, ".")
    axis([i-0.5,i+0.5,j-0.5,j+0.5])
    for ax in [:xaxis,:yaxis]
        gca()[ax][:set_major_locator](MultipleLocator(1))
        gca()[ax][:set_minor_locator](MultipleLocator(0.1))
    end
    grid(which="major", linewidth=1.0)
    grid(which="minor", linewidth=0.5)
end

figure(1,figsize=(8,4))
clf()
subplot(121)
test_sampling(SingleSampler())
title("Single sample")
subplot(122)
test_sampling(JitteredSampler(100))
title("Jittered sampling")
tight_layout()
savefig("sampling.png", dpi=200)
