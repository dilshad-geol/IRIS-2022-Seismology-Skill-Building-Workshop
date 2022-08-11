k = 20
p = 1
c = 30.0/3600/24

#print(c)

t = 0
while t <= 40:
    n = k / (c + t) ** p
    print(t, n)
    t = t+.5
