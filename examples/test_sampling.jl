using Rayly

using PyCall
pygui(:qt)
using PyPlot
matplotlib[:rcdefaults]()

function test_sampling(s)
    i,j = 10.,9.
    samples = s(i,j)
    x,y = zip(samples...)
    plot(x,y, ".")
    axis([i-0.5,i+0.5,j-0.5,j+0.5])
end

figure(1,figsize=(8,4))
clf()
subplot(121)
test_sampling(SingleSampler())
title("Single sample")
subplot(122)
test_sampling(JitteredSampler(25))
title("Jittered sampling")
tight_layout()
savefig("sampling.png")
